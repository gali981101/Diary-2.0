//
//  AboutTableViewController.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/26.
//

import UIKit
import SafariServices

class AboutTableViewController: UITableViewController {
    
    enum Section {
        case feedback, followus
    }
    
    struct LinkItem: Hashable {
        var text: String
        var link: String
        var image: String
    }
    
    let section0 = [
        LinkItem(text: NSLocalizedString("Rate me on App Store", comment: "Rate me on App Store"), link: "https://www.apple.com/ios/app-store/", image: "store"),
        LinkItem(text: NSLocalizedString("Tell us your feedback", comment: "Tell us your feedback"), link: "https://www.youtube.com/", image: "chat")
    ]
    
    let section1 = [
        LinkItem(text: NSLocalizedString("Twitter", comment: "Twitter"), link: "https://twitter.com/?lang=zh-Hant", image: "twitter"),
        LinkItem(text: NSLocalizedString("Facebook", comment: "Facebook"), link: "https://www.facebook.com/?locale=zh_TW", image: "facebook"),
        LinkItem(text: NSLocalizedString("Instagram", comment: "Instagram"), link: "https://www.instagram.com/", image: "instagram")
    ]
    
    lazy var sectionContent: [[LinkItem]] = [section0, section1]
    lazy var dataSource = configureDataSource()
    
}

// MARK: - Life Cycle

extension AboutTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.dataSource = dataSource
        updateSnapshot()
    }
    
}

// MARK: - Snapshot

extension AboutTableViewController {
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, LinkItem>()
        
        snapshot.appendSections([.feedback, .followus])
        
        snapshot.appendItems(section0, toSection: .feedback)
        snapshot.appendItems(section1, toSection: .followus)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}

// MARK: - DiffableDataSource

extension AboutTableViewController {
    
    private func configureDataSource() -> UITableViewDiffableDataSource<Section, LinkItem> {
        
        let cellIdentifier = "aboutCell"
        
        let dataSource = UITableViewDiffableDataSource<Section, LinkItem>(tableView: tableView) { tableView, indexPath, linkItem in
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            var content = cell.defaultContentConfiguration()
            
            content.text = linkItem.text
            content.image = UIImage(named: linkItem.image)
            
            cell.contentConfiguration = content
            return cell
        }
        
        return dataSource
        
    }
    
}

// MARK: - UITableViewDelegate

extension AboutTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: "showWebView", sender: self)
        case 1:
            openWithSafariVC(of: indexPath)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        
    }
    
}

// MARK: - SFSafari

extension AboutTableViewController {
    
    private func openWithSafariVC(of indexPath: IndexPath) {
        guard let linkItem = self.dataSource.itemIdentifier(for: indexPath) else { return }
        guard let url = URL(string: linkItem.link) else { return }

        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
}

// MARK: - Segue

extension AboutTableViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView" {
            guard let destinationVC = segue.destination as? WebViewController, 
                    let indexPath = tableView.indexPathForSelectedRow, 
                    let linkItem = self.dataSource.itemIdentifier(for: indexPath) else { return }
            
            destinationVC.targetURL = linkItem.link
        }
    }
    
}
