//
//  DiaryDiffableDataSource.swift
//  Diary
//
//  Created by Terry Jason on 2023/12/21.
//

import UIKit

enum Section {
    case all
}

class DiaryDiffableDataSource: UITableViewDiffableDataSource<Section, Diary> {
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}
