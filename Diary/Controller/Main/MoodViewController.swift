//
//  MoodViewController.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/23.
//

import UIKit

class MoodViewController: UIViewController {
    
    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var moodButtons: [UIButton]!
    @IBOutlet var closeButton: UIButton!
    
    var diary = Diary()
    
    let moveLeftTransform = CGAffineTransform.init(translationX: -600, y: 0)
    let scaleUpTransform = CGAffineTransform.init(scaleX: 5.0, y: 5.0)
    
    lazy var delayCount: Double = 0.1
    
}

// MARK: - Life Cycle

extension MoodViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgImageView.image = UIImage(data: diary.image)
        
        let moveScaleTransform = scaleUpTransform.concatenating(moveLeftTransform)
        
        closeButton.transform = moveScaleTransform
        closeButton.alpha = 0
        
        for moodButton in moodButtons {
            moodButton.transform = moveScaleTransform
            moodButton.alpha = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        for i in 0...(moodButtons.count - 1) {
            UIView.animate(withDuration: 0.4, delay: TimeInterval(delayCount)) {
                self.moodButtons[i].alpha = 1.0
                self.moodButtons[i].transform = .identity
                
                if i == 3 {
                    self.closeButton.alpha = 1.0
                    self.closeButton.transform = .identity
                }
            }
            delayCount += 0.05
        }
        
    }
    
}

