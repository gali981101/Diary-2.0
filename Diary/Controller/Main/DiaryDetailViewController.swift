//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/22.
//

import UIKit

class DiaryDetailViewController: UIViewController {
    
    var diary: Diary!
    
    // MARK: - Navigation Item
    
    lazy var heartButton = UIBarButtonItem(image: nil, style: .done, target: self, action: #selector(heartButtonPressed))
    
    // MARK: - @IBOulet
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: DiaryDetailHeaderView!
    
}

// MARK: - Life Cycle

extension DiaryDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.rightBarButtonItem  = heartButton
        
        headerView.titleLabel.text = diary.title
        headerView.weatherLabel.text = diary.weather
        headerView.headerImageView.image = UIImage(data: diary.image)
        
        let heartImage = diary.isFavorite ? "heart.fill" : "heart"
        
        heartButton.tintColor = .systemMint
        heartButton.image = UIImage(systemName: heartImage)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        
        if let mood = diary.mood {
            headerView.moodImageView.image = UIImage(named: mood.rawValue)
        }
    }
    
}

// MARK: - @IBAction

extension DiaryDetailViewController {
    
    @IBAction func close(segue: UIStoryboardSegue) {
        dismiss(animated: true)
    }
    
    @IBAction func diaryMood(segue: UIStoryboardSegue) {
        guard let mood = segue.identifier else { return }
        
        dismiss(animated: true) {
            self.diary.moodText = mood
            self.headerView.moodImageView.image = UIImage(named: mood)
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                appDelegate.saveContext()
            }
            
            let scaleTransform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
            
            self.headerView.moodImageView.transform = scaleTransform
            self.headerView.moodImageView.alpha = 0
            
            self.uiviewAnimate()
        }
    }
    
}

// MARK: - Func

extension DiaryDetailViewController {
    
    private func uiviewAnimate() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.7) {
            self.headerView.moodImageView.transform = .identity
            self.headerView.moodImageView.alpha = 1
        }
    }
    
}

// MARK: - @Objc Func

extension DiaryDetailViewController {
    
    @objc private func heartButtonPressed() {
        diary.isFavorite.toggle()
        
        heartButton.image = UIImage(systemName: diary.isFavorite ? "heart.fill" : "heart")
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            appDelegate.saveContext()
        }
    }
    
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension DiaryDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: DiaryDetailTextCell.self),
                for: indexPath
            ) as! DiaryDetailTextCell
            
            cell.isUserInteractionEnabled = false
            cell.descriptionLabel.text = diary.summary
            
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: DiaryDetailTwoColumnCell.self),
                for: indexPath
            ) as! DiaryDetailTwoColumnCell
            
            cell.isUserInteractionEnabled = false
            
            cell.column1TitleLabel.text = NSLocalizedString("Location", comment: "Location")
            cell.column1TextLabel.text = diary.location
            
            cell.column2TitleLabel.text = NSLocalizedString("Date", comment: "Date")
            cell.column2TextLabel.text = diary.date
            
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: DiaryDetailMapCell.self),
                for: indexPath
            ) as! DiaryDetailMapCell
            
            cell.configure(in: diary.location)
            cell.selectionStyle = .none
            
            return cell
            
        default:
            fatalError("Failed to instantiate the table view cell")
        }
    }
    
}

// MARK: - Segue

extension DiaryDetailViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showMap":
            let destinationVC = segue.destination as! MapViewController
            destinationVC.diary = self.diary
        case "showMood":
            let destinationVC = segue.destination as! MoodViewController
            destinationVC.diary = self.diary
        default:
            break
        }
    }
    
}


