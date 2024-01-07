//
//  DiaryTableViewController.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/21.
//

import UIKit
import CoreData
import UserNotifications

class DiaryTableViewController: SwipeTableViewController {
    
    lazy var dataSource = configureDataSource()
    
    var arrIndexPath: [IndexPath] = []
    
}

// MARK: - Life Cycle

extension DiaryTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        fetchDiaryData()
        prepareNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") { return }
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        guard let walkthroughVC = storyboard.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController else { return }
        
        present(walkthroughVC, animated: true)
    }
    
}

// MARK: - @IBAction

extension DiaryTableViewController {
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        dismiss(animated: true)
    }
    
}

// MARK: - DiffableDataSource

extension DiaryTableViewController {
    
    private func configureDataSource() -> UITableViewDiffableDataSource<Section, Diary> {
        
        let cellIdentifier = "dataCell"
        
        let dataSource = DiaryDiffableDataSource(tableView: tableView) { tableView, indexPath, diary in
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DiaryTableViewCell
            
            cell.titleLabel.text = diary.title
            cell.locationLabel.text = diary.location
            cell.dateLabel.text = diary.date
            
            cell.thumbnailImageView.image = UIImage(data: diary.image)
            
            return cell
        }
        
        return dataSource
        
    }
    
}

// MARK: - UITableViewDelegate

extension DiaryTableViewController {
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if searchController.isActive { return UISwipeActionsConfiguration() }
        
        guard let diary = dataSource.itemIdentifier(for: indexPath) else { return UISwipeActionsConfiguration() }
        
        let delete = deleteContextualAction(diary)
        let share = shareContextualAction(diary, at: indexPath)
        
        delete.backgroundColor = UIColor.systemRed
        delete.image = UIImage(systemName: "trash")
        
        share.backgroundColor = UIColor.systemMint
        share.image = UIImage(systemName: "square.and.arrow.up")
        
        return UISwipeActionsConfiguration(actions: [delete, share])
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let diary = dataSource.itemIdentifier(for: indexPath) else { return nil }
        return contextMenuConfiguration(diary: diary, of: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !(arrIndexPath.contains(indexPath)) else { return }
        
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 200, 0)
        
        cell.alpha = 0
        cell.layer.transform = rotationTransform
        
        UIView.animate(withDuration: 1.0, animations: {
            cell.alpha = 1
            cell.layer.transform = CATransform3DIdentity
        })
        
        arrIndexPath.append(indexPath)
    }
    
}

// MARK: - UIContextualAction

extension DiaryTableViewController {
    
    private func deleteContextualAction(_ item: Diary) -> UIContextualAction {
        return UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "Delete")) { action, sourceView, completionHandler in
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                context.delete(item)
                
                appDelegate.saveContext()
                
                self.updateSnapshot(animatingChange: true)
            }
            
            completionHandler(true)
        }
    }
    
}

// MARK: - UISearchResultsUpdating

extension DiaryTableViewController {
    
    override func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        fetchDiaryData(searchText: searchText)
    }
    
}

// MARK: - Core Data

extension DiaryTableViewController {
    
    private func fetchDiaryData(searchText: String = "") {
        let fetchRequest: NSFetchRequest<Diary> = Diary.fetchRequest()
        
        if !(searchText.isEmpty) {
            fetchRequest.predicate = orCompoundPredicate(searchText: searchText)
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

// MARK: - User Notification

extension DiaryTableViewController {
    
    private func prepareNotification() {
        let recommendDiaries = noFavoriteDiaries()
        
        if recommendDiaries.isEmpty { return }
        
        let randomNum = Int.random(in: 0..<recommendDiaries.count)
        let suggestedDiary = recommendDiaries[randomNum]
        
        let categoryId = "diary.diaryaction"
        let content = notificationContent(suggestedDiary, categoryId)
        
        notificationAction(categoryId: categoryId)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "diary.diarySuggestion", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func noFavoriteDiaries() -> [Diary] {
        var array: [Diary] = []
        
        for diary in diaries {
            if !(diary.isFavorite) {
                array.append(diary)
            }
        }
        return array
    }
    
    private func notificationContent(_ item: Diary, _ categoryId: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        
        content.title = "Diary Review"
        content.subtitle = "Review this story"
        
        content.body = "Do you want to check out \(item.title).This diary is one of your daliy journal. It's happened on \(item.date). Would you want to add it to favorites?"
        
        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFileURL = tempDirURL.appending(components: "suggested-diary.png")
        
        if let image = UIImage(data: item.image as Data) {
            try? image.pngData()?.write(to: tempFileURL)
            
            if let diaryImage = try? UNNotificationAttachment(identifier: "diaryImage", url: tempFileURL) {
                content.attachments = [diaryImage]
            }
        }
        
        content.categoryIdentifier = categoryId
        content.sound = UNNotificationSound.default
        
        return content
    }
    
    private func notificationAction(categoryId: String) {
        let addFavoriteAction = UNNotificationAction(identifier: "diary.addFavorite", title: "Add to favorites", options: [.foreground])
        let cancelAction = UNNotificationAction(identifier: "diary.cancel", title: "Later")
        
        let category = UNNotificationCategory(identifier: categoryId, actions: [addFavoriteAction, cancelAction], intentIdentifiers: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
}


