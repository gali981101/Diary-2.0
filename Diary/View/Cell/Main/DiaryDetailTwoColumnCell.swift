//
//  DiaryDetailTwoColumnCell.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/22.
//

import UIKit

class DiaryDetailTwoColumnCell: UITableViewCell {

    @IBOutlet var column1TitleLabel: UILabel! {
        didSet {
            column1TitleLabel.numberOfLines = 0
            column1TitleLabel.text = column1TitleLabel.text?.uppercased()
        }
    }
    
    @IBOutlet var column1TextLabel: UILabel! {
        didSet {
            column1TextLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var column2TitleLabel: UILabel! {
        didSet {
            column2TitleLabel.numberOfLines = 0
            column2TitleLabel.text = column2TitleLabel.text?.uppercased()
        }
    }
    
    @IBOutlet var column2TextLabel: UILabel! {
        didSet {
            column2TextLabel.numberOfLines = 0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
