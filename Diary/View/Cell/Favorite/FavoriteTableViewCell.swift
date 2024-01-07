//
//  FavoriteTableViewCell.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/27.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet var weatherLabel: UILabel!
    
    @IBOutlet var summaryLabel: UILabel!
    
    @IBOutlet var thumbnailImageView: UIImageView! {
        didSet {
            thumbnailImageView.layer.cornerRadius = 20.0
            thumbnailImageView.clipsToBounds = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = .systemMint
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
