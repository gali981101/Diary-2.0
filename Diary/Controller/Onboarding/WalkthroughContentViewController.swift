//
//  WalkthroughContentViewController.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/26.
//

import UIKit

class WalkthroughContentViewController: UIViewController {
    
    var index: Int = 0
    
    var heading: String = ""
    
    var subHeading: String = ""
    
    var imageFile: String = ""
    
    // MARK: - @IBOulet
    
    @IBOutlet var headingLabel: UILabel! {
        didSet {
            headingLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var subHeadingLabel: UILabel! {
        didSet {
            subHeadingLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var contentImageView: UIImageView!
    
}

// MARK: - Life Cycle

extension WalkthroughContentViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headingLabel.text = heading
        subHeadingLabel.text = subHeading
        
        contentImageView.image = UIImage(named: imageFile)
    }
    
}
