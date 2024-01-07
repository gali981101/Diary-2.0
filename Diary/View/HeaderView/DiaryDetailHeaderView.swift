//
//  DiaryDetailHeaderView.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/22.
//

import UIKit

class DiaryDetailHeaderView: UIView {
    
    @IBOutlet var headerImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 0
            
            guard let customFont = UIFont(name: "RubikDoodleShadow-Regular", size: 40.0) else { return }
            titleLabel.font = UIFontMetrics(forTextStyle: .title2).scaledFont(for: customFont)
        }
    }
    
    @IBOutlet var weatherLabel: UILabel! {
        didSet {
            weatherLabel.numberOfLines = 1
            
            guard let customFont = UIFont(name: "RubikDoodleShadow-Regular", size: 30.0) else { return }
            weatherLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont)
        }
    }
    
    @IBOutlet var moodImageView: UIImageView!
    
}
