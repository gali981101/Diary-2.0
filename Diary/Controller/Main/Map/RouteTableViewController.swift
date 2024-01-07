//
//  RouteTableViewController.swift
//  Diary
//
//  Created by Terry Jason on 2024/1/3.
//

import UIKit
import MapKit

class RouteTableViewController: UITableViewController {
    
    var routeSteps = [MKRoute.Step]()
    
}

// MARK: - Life Cycle

extension RouteTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

// MARK: - @IBAction

extension RouteTableViewController {
    
    @IBAction func close() {
        dismiss(animated: true)
    }
    
}

// MARK: - Table view data source

extension RouteTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routeSteps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stepsCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = routeSteps[indexPath.row].instructions

        cell.contentConfiguration = content
        
        return cell
    }
    
}
