//
//  WebViewController.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/26.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet var webView: WKWebView!
    
    var targetURL: String = ""
    
}

// MARK: - Life Cycle

extension WebViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: targetURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
}
