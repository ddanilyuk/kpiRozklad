//
//  GroupsAndTeachersVC+Search.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 31.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

//MARK: - extencions for search
extension GroupsAndTeachersViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        let lowerCaseSearchText = searchText.lowercased()
        
        groupsInSearch = []
        teachersInSearch = []
        
        if searchText == "" {
            isSearching = false
            activityIndicator.stopAndHide()
            switch groupAndTeacherControllerType {
            case .isGroupChooser, .isTeachersChooser:
                startWriteLabel.isHidden = false
                tableView.isHidden = true
            default:
                break
            }
            
        } else {
            isSearching = true
            startWriteLabel.isHidden = true
            tableView.isHidden = false
            
            switch groupAndTeacherControllerType {
            case .isTeachersChooser, .isTeacherViewController:
                if teachers.isEmpty {
                    tableView.isHidden = true
                    activityIndicator.startAndShow()
                }
                teachersInSearch = teachers.filter{ $0.teacherName.lowercased().contains(lowerCaseSearchText) }
                
            case .isGroupChooser, .isGroupViewController:
                if groups.isEmpty {
                    tableView.isHidden = true
                    activityIndicator.startAndShow()
                }
                groupsInSearch = groups.filter { $0.groupFullName.lowercased().contains(lowerCaseSearchText) }
            }
        }
        tableView.reloadData()
    }
    
}
