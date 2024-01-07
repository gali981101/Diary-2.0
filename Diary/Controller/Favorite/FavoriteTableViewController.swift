//
//  FavoriteTableViewController.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/27.
//

import UIKit
import CoreData

class FavoriteTableViewController: SwipeTableViewController {
    
    lazy var dataSource = configureDataSource()
    
}

// MARK: - Life Cycle

extension FavoriteTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchBar.placeholder = NSLocalizedString("Search favorite diaries...", comment: "Search favorite diaries...")
        
        tableView.dataSource = dataSource
        fetchFavoriteDiaryData()
    }
    
}

// MARK: - DiffableDataSource

extension FavoriteTableViewController {
    
    private func configureDataSource() -> UITableViewDiffableDataSource<Section, Diary> {
        
        let cellIdentifier = "favoriteCell"
        
        let dataSource = DiaryDiffableDataSource(tableView: tableView) { tableView, indexPath, diary in
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FavoriteTableViewCell
            
            cell.titleLabel.text = diary.title
            cell.locationLabel.text = diary.location
            cell.weatherLabel.text = diary.weather
            cell.summaryLabel.text = diary.summary
            
            cell.thumbnailImageView.image = UIImage(data: diary.image)
            
            return cell
        }
        
        return dataSource
        
    }
    
}

// MARK: - UITableViewDelegate

extension FavoriteTableViewController {
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if searchController.isActive { return UISwipeActionsConfiguration() }
        
        guard let diary = dataSource.itemIdentifier(for: indexPath) else { return UISwipeActionsConfiguration() }
        
        let remove = removeContextualAction(diary)
        let share = shareContextualAction(diary, at: indexPath)
        
        remove.backgroundColor = UIColor.systemPink
        remove.image = UIImage(systemName: "heart.slash")
        
        share.backgroundColor = UIColor.systemMint
        share.image = UIImage(systemName: "square.and.arrow.up")
        
        return UISwipeActionsConfiguration(actions: [remove, share])
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let diary = dataSource.itemIdentifier(for: indexPath) else { return nil }
        return contextMenuConfiguration(diary: diary, of: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let rotationAngleInRadius = 90.0 * CGFloat(Double.pi/180.0)
        let rotationTransform = CATransform3DMakeRotation(rotationAngleInRadius, 0, 0, 1)
        
        cell.alpha = 0
        cell.layer.transform = rotationTransform
        
        UIView.animate(withDuration: 1.0, animations: {
            cell.alpha = 1
            cell.layer.transform = CATransform3DIdentity
        })
    }
    
}

// MARK: - UIContextualAction

extension FavoriteTableViewController {
    
    private func removeContextualAction(_ item: Diary) -> UIContextualAction {
        return UIContextualAction(style: .destructive, title: NSLocalizedString("Remove", comment: "Remove")) { action, sourceView, completionHandler in
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                item.isFavorite = false
                appDelegate.saveContext()
                
                self.updateSnapshot(animatingChange: true)
            }
            
            completionHandler(true)
        }
    }
    
}

// MARK: - UISearchResultsUpdating

extension FavoriteTableViewController {
    
    override func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        fetchFavoriteDiaryData(searchText: searchText)
    }
    
}

// MARK: - Core Data

extension FavoriteTableViewController {
    
    private func fetchFavoriteDiaryData(searchText: String = "") {
        let fetchRequest: NSFetchRequest<Diary> = Diary.fetchRequest()
        
        if !(searchText.isEmpty) {
            fetchRequest.predicate = andCompoundPredicate(searchText: searchText)
        } else {
            fetchRequest.predicate = favoritePredicate(searchText)
        }
        
        sort(fetchRequest)
        
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: createContext(), sectionNameKeyPath: nil, cacheName: nil)
        fetchResultController.delegate = self
        
        do {
            try fetchResultController.performFetch()
            updateSnapshot()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
    
    private func updateSnapshot(animatingChange: Bool = false) {
        guard let fetchedObjects = fetchResultController.fetchedObjects else { return }
        diaries = fetchedObjects
        dataSource.apply(snapshotSet(diaries), animatingDifferences: animatingChange)
    }
    
}


