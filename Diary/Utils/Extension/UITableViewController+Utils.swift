//
//  UITableViewController+Utils.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/27.
//

import UIKit
import CoreData

// MARK: - Life Cycle

extension UITableViewController {
    
    open override func viewDidLoad() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let appearance = navigationController?.navigationBar.standardAppearance {
            guard let customFont = UIFont(name: "RubikDoodleShadow-Regular", size: 45.0) else { return }
            
            appearance.configureWithOpaqueBackground()
            
            appearance.titleTextAttributes = [.foregroundColor: UIColor.systemMint]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.systemMint, .font: customFont]
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
}

