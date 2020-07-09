//
//  GroupsAndTeachersVC+UITableView.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 31.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


extension GroupsAndTeachersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch groupAndTeacherControllerType {
        case .isTeachersChooser, .isTeacherViewController:
            return isSearching ? teachersInSearch.count : teachers.count
        case .isGroupChooser, .isGroupViewController:
            return isSearching ? groupsInSearch.count : groups.count
        }
//        if isSheduleTeachersChooser || isTeacherViewController {
//            if isSearching {
//                return teachersInSearch.count
//            } else {
//                return teachers.count
//            }
//        } else {
//            if isSearching {
//                return groupsInSearch.count
//            } else {
//                return groups.count
//            }
//        }
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TeacherOrGroupLoadingTableViewCell.identifier, for: indexPath) as? TeacherOrGroupLoadingTableViewCell else { return UITableViewCell() }
        
        cell.activityIndicator.stopAndHide()
        
        switch groupAndTeacherControllerType {
        case .isTeachersChooser, .isTeacherViewController:
            cell.mainLabel.text = isSearching ? teachersInSearch[indexPath.row].teacherName : teachers[indexPath.row].teacherName
        case .isGroupChooser, .isGroupViewController:
            cell.mainLabel.text = isSearching ? groupsInSearch[indexPath.row].groupFullName : groups[indexPath.row].groupFullName
        }
        
//        if isSheduleTeachersChooser || isTeacherViewController {
//            cell.mainLabel.text = isSearching ? teachersInSearch[indexPath.row].teacherName : teachers[indexPath.row].teacherName
//        } else {
//            cell.mainLabel.text = isSearching ? groupsInSearch[indexPath.row].groupFullName : groups[indexPath.row].groupFullName
//        }

        return cell
    }
        

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let window = appDelegate?.window else { return }
        guard let mainTabBar: UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as? UITabBarController else { return }
        
        switch groupAndTeacherControllerType {
        case .isTeachersChooser :
            let teacher = isSearching ? teachersInSearch[indexPath.row] : teachers[indexPath.row]
            
            settings.teacherName = teacher.teacherName
            settings.teacherID = teacher.teacherID
            
            settings.isTryToRefreshShedule = true
            
            if #available(iOS 13, *) {
                self.dismiss(animated: true, completion: {
                    window.rootViewController = mainTabBar
                })
            } else {
                window.rootViewController = mainTabBar
                window.makeKeyAndVisible()
            }
            
        case .isGroupChooser:
            let group = isSearching ? groupsInSearch[indexPath.row] : groups[indexPath.row]

            settings.groupName = group.groupFullName
            settings.groupID = group.groupID
            
            settings.isTryToRefreshShedule = true

            if #available(iOS 13, *) {
                self.dismiss(animated: true, completion: {
                    window.rootViewController = mainTabBar
                })
            } else {
                window.rootViewController = mainTabBar
                window.makeKeyAndVisible()
            }

        case .isGroupViewController:
            let group = isSearching ? groupsInSearch[indexPath.row] : groups[indexPath.row]
            getGroupLessons(group: group, indexPath: indexPath)
        case .isTeacherViewController:
            let teacher = isSearching ? teachersInSearch[indexPath.row] : teachers[indexPath.row]
            getTeacherLessons(teacher: teacher, indexPath: indexPath)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
