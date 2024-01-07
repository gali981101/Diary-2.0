//
//  WalkthroughPageViewController.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/26.
//

import UIKit

// MARK: - WalkthroughPageViewControllerDelegate

protocol WalkthroughPageViewControllerDelegate: AnyObject {
    func didUpdatePageIndex(currentIndex: Int)
}

// MARK: - WalkthroughPageViewController

class WalkthroughPageViewController: UIPageViewController {
    
    var pageImages: [String] = ["onboarding-1", "onboarding-2", "onboarding-3"]
    
    var pageHeadings: [String] = ["RECORD YOUR LIFE", "WRITE DOWN YOUR THOUGHTS AND MOOD", "MARK YOUR FAVORITE DIARY"]
    var pageSubHeadings: [String] = ["Create your own diary list", "Write down your thoughts, mood, place and weather at that time", "Pin your favorite diaries"]
    
    var currentIndex = 0
    
    weak var walkthroughDelegate: WalkthroughPageViewControllerDelegate?
    
}

// MARK: - Life Cycle

extension WalkthroughPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let startingViewController = contentViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true)
        }
    }
    
}

// MARK: - Func

extension WalkthroughPageViewController {
    
    func forwardPage() {
        currentIndex += 1
        guard let nextVC = contentViewController(at: currentIndex) else { return }
        setViewControllers([nextVC], direction: .forward, animated: true)
    }
    
}

// MARK: - UIPageViewControllerDataSource

extension WalkthroughPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index -= 1
        
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughContentViewController).index
        index += 1
        
        return contentViewController(at: index)
    }
    
    private func contentViewController(at index: Int) -> WalkthroughContentViewController? {
        if index < 0 || index >= pageHeadings.count { return nil }
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        
        guard let pageContentVC = storyboard.instantiateViewController(withIdentifier: "WalkthroughContentViewController") as? WalkthroughContentViewController else { return nil }
        
        pageContentVC.imageFile = pageImages[index]
        pageContentVC.heading = pageHeadings[index]
        pageContentVC.subHeading = pageSubHeadings[index]
        
        pageContentVC.index = index
        
        return pageContentVC
    }
    
}

// MARK: - UIPageViewControllerDelegate

extension WalkthroughPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            guard let contentVC = pageViewController.viewControllers?.first as? WalkthroughContentViewController else { return }
            currentIndex = contentVC.index
            walkthroughDelegate?.didUpdatePageIndex(currentIndex: contentVC.index)
        }
    }
    
}
