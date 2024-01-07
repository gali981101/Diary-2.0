//
//  WalkthroughViewController.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/26.
//

import UIKit

class WalkthroughViewController: UIViewController {
    
    var walkthroughPageVC: WalkthroughPageViewController?
    
    // MARK: - @IBOulet
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var nextButton: UIButton! {
        didSet {
            nextButton.layer.cornerRadius = 25.0
            nextButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var skipButton: UIButton!
    
}

// MARK: - Life Cycle

extension WalkthroughViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

// MARK: - @IBACtion

extension WalkthroughViewController {
    
    @IBAction func nextButtonTapped(sender: UIButton) {
        guard let index = walkthroughPageVC?.currentIndex else { return }
        
        switch index {
        case 0...1:
            walkthroughPageVC?.forwardPage()
        case 2:
            UserDefaults.standard.setValue(true, forKey: "hasViewedWalkthrough")
            createQuickActions()
            dismiss(animated: true)
        default:
            break
        }
        
        updateUI()
    }
    
    @IBAction func skipButtonTapped(sender: UIButton) {
        UserDefaults.standard.setValue(true, forKey: "hasViewedWalkthrough")
        createQuickActions()
        dismiss(animated: true)
    }
    
}

// MARK: - Segue

extension WalkthroughViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? WalkthroughPageViewController else { return }
        walkthroughPageVC = destinationVC
        walkthroughPageVC?.walkthroughDelegate = self
    }
    
}

// MARK: - Func

extension WalkthroughViewController {
    
    private func updateUI() {
        guard let index = walkthroughPageVC?.currentIndex else { return }
        
        switch index {
        case 0...1:
            nextButton.setTitle("NEXT", for: .normal)
            skipButton.isHidden = false
        case 2:
            nextButton.setTitle("GET STARTED", for: .normal)
            skipButton.isHidden = true
        default:
            break
        }
        
        pageControl.currentPage = index
    }
    
}

// MARK: - WalkthroughPageViewControllerDelegate

extension WalkthroughViewController: WalkthroughPageViewControllerDelegate {
    
    func didUpdatePageIndex(currentIndex: Int) {
        updateUI()
    }
    
}

// MARK: - Shortcut

extension WalkthroughViewController {
    
    func createQuickActions() {
        guard let bundleId = Bundle.main.bundleIdentifier else { return }
        
        let shortCutItem1 = UIApplicationShortcutItem(
            type: "\(bundleId).OpenFavorites",
            localizedTitle: "Show Favorites",
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(systemImageName: "tag")
        )
        
        let shortCutItem2 = UIApplicationShortcutItem(
            type: "\(bundleId).OpenMain",
            localizedTitle: "Main Page",
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(systemImageName: "house")
        )
        
        let shortCutItem3 = UIApplicationShortcutItem(
            type: "\(bundleId).NewDiary",
            localizedTitle: "New Diary",
            localizedSubtitle: nil,
            icon: UIApplicationShortcutIcon(type: .add)
        )
        
        UIApplication.shared.shortcutItems = [shortCutItem1, shortCutItem2, shortCutItem3]
    }
    
}







