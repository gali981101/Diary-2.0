//
//  SwipeTableViewController.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/28.
//

import UIKit
import CoreData

class SwipeTableViewController: UITableViewController {
    
    var cellIdentifier: String!
    
    var diaries: [Diary]!
    
    var fetchResultController: NSFetchedResultsController<Diary>!
    var searchController: UISearchController!
    
}

// MARK: - Life Cycle

extension SwipeTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.placeholder = NSLocalizedString("Search diaries...", comment: "Search diaries...")
        searchController.searchBar.tintColor = .systemMint
        searchController.searchBar.searchBarStyle = .prominent
        
        tableView.cellLayoutMarginsFollowReadableWidth = true
        tableView.separatorStyle = .none
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
}

// MARK: - UITableViewDelegate

extension SwipeTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive { searchController.isActive = false }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
        guard let selectedRow = configuration.identifier as? Int else { return }
        guard let diaryDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else {
            return
        }
        
        diaryDetailVC.diary = diaries[selectedRow]
        
        animator.preferredCommitStyle = .pop
        animator.addCompletion {
            self.show(diaryDetailVC, sender: self)
        }
    }
    
}

// MARK: - Prepare Segue

extension SwipeTableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDiaryDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let destinationVC = segue.destination as! DiaryDetailViewController
            
            destinationVC.diary = diaries[indexPath.row]
            destinationVC.hidesBottomBarWhenPushed = true
        }
    }
    
}

// MARK: - UISearchResultsUpdating

extension SwipeTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {}
}

// MARK: - Handle

extension UITableViewController {
    
    private func shareActionHandle(_ item: Diary, at index: IndexPath) {
        
        let activityController: UIActivityViewController
        
        let defatltText = NSLocalizedString("Look at this story \(item.title)", comment: "Look at this story \(item.title)")
        
        if let imageToShare = UIImage(data: item.image) {
            activityController = UIActivityViewController(activityItems: [defatltText, imageToShare], applicationActivities: nil)
        } else {
            activityController = UIActivityViewController(activityItems: [defatltText], applicationActivities: nil)
        }
        
        if let popoverController = activityController.popoverPresentationController {
            guard let cell = self.tableView.cellForRow(at: index) else { fatalError() }
            
            popoverController.sourceView = cell
            popoverController.sourceRect = cell.bounds
        }
        
        self.present(activityController, animated: true)
    }
    
    private func deleteActionHandle(_ item: Diary) {
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            context.delete(item)
            
            appDelegate.saveContext()
        }
    }
    
}

// MARK: - UIAction

extension UITableViewController {
    
    private func favoriteAction(_ item: Diary, _ favoritePressed: Bool) -> UIAction {
        let status: [String] = favoritePressed ? ["Remove from favorite", "heart.slash"] : ["Save as favorite", "heart"]
        
        return UIAction(title: status[0], image: UIImage(systemName: status[1])) { _ in
            item.isFavorite.toggle()
            
            guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate) else { return }
            appDelegate.saveContext()
        }
    }
    
    private func shareAction(_ item: Diary, at index: IndexPath) -> UIAction {
        return UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            self.shareActionHandle(item, at: index)
        }
    }
    
    private func deleteAction(_ item: Diary) -> UIAction {
        return UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            self.deleteActionHandle(item)
        }
    }
    
}

// MARK: - UIContextualAction

extension UITableViewController {
    
    func shareContextualAction(_ item: Diary, at index: IndexPath) -> UIContextualAction {
        return UIContextualAction(style: .normal, title: NSLocalizedString("Share", comment: "Share")) { action, sourceView, completionHandler in
            self.shareActionHandle(item, at: index)
            completionHandler(true)
        }
    }
    
}

// MARK: - UIContextMenuConfiguration

extension UITableViewController {
    
    func contextMenuConfiguration(diary item: Diary, of index: IndexPath) -> UIContextMenuConfiguration {
        
        return UIContextMenuConfiguration(identifier: index.row as NSCopying) {
            guard let diaryDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else {
                return nil
            }
            
            diaryDetailVC.diary = item
            
            return diaryDetailVC
        } actionProvider: { _ in
            let favorite = self.favoriteAction(item, item.isFavorite)
            let share = self.shareAction(item, at: index)
            let delete = self.deleteAction(item)
            
            return UIMenu(title: "", children: [favorite, share, delete])
        }
        
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension UITableViewController: NSFetchedResultsControllerDelegate {
    
    func favoritePredicate(_ searchText: String) -> NSPredicate {
        return NSPredicate(format: "isFavorite = %d", true)
    }
    
    private func titlePredicate(_ searchText: String) -> NSPredicate {
        return NSPredicate(format: "title CONTAINS[c] %@", searchText)
    }
    
    private func locationPredicate(_ searchText: String) -> NSPredicate {
        return NSPredicate(format: "location CONTAINS[c] %@", searchText)
    }
    
    func orCompoundPredicate(searchText: String) -> NSPredicate {
        return NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate(searchText), locationPredicate(searchText)])
    }
    
    func andCompoundPredicate(searchText: String) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [favoritePredicate(searchText), orCompoundPredicate(searchText: searchText)])
    }
    
    func sort(_ fetchRequest: NSFetchRequest<Diary>) {
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
    }
    
    func createContext() -> NSManagedObjectContext {
        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate) else { fatalError() }
        let context = appDelegate.persistentContainer.viewContext
        return context
    }
    
    func snapshotSet(_ items: [Diary]) -> NSDiffableDataSourceSnapshot<Section, Diary> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Diary>()
        snapshot.appendSections([.all])
        snapshot.appendItems(items, toSection: .all)
        
        return snapshot
    }
    
}
