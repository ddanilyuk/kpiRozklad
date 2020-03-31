//
//  GroupsAndTeachersVC+Search.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 31.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

//Mark: - extencions for search
extension GroupsAndTeachersViewController: UISearchResultsUpdating {

        // MARK: - updateSearchResults
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text else { return }
        
        let lowerCaseSearchText = searchText.lowercased()
        
        if searchText == "" {
            isSearching = false
            groupsInSearch = []
            teachersInSearch = []

            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            
            if isSheduleGroupChooser || isSheduleTeachersChooser {
                startWriteLabel.isHidden = false
                tableView.isHidden = true
            }
            
            tableView.reloadData()
            return
        }
        
        if isSheduleTeachersChooser || isTeacherViewController {
            isSearching = true
            teachersInSearch = []
            
            startWriteLabel.isHidden = true
            tableView.isHidden = false

            if teachers.count == 0 {
                tableView.isHidden = true
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
            }
            
            for teacher in teachers {
                if teacher.teacherFullName.lowercased().contains(lowerCaseSearchText){
                    teachersInSearch.append(teacher)
                }
            }
            
        } else {
            isSearching = true
            groupsInSearch = []
            
            startWriteLabel.isHidden = true
            tableView.isHidden = false

            if groups.count == 0 {
                tableView.isHidden = true
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
            }
            
            for group in groups {
                if group.groupFullName.lowercased().contains(lowerCaseSearchText){
                    groupsInSearch.append(group)
                }
            }
        }
        
        tableView.reloadData()
    }
    
}
