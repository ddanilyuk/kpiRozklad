//
//  GroupsAndTeachersVC+ServerApi.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 18.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit
import PromiseKit


extension GroupsAndTeachersViewController {
    
    enum AlertCase {
        case getGroupLessonsType
        case getTeacherLessonsType
        case getAllGroupType
        case getAllTeachersType
        case getTeachersOfGroupType
        
    }
    
    func getDefaultErrorAlert(localizedDescription: String, alertCase: AlertCase, group: Group?, teacher: Teacher?, indexPath: IndexPath?) {
        
        if let cell = tableView.cellForRow(at: indexPath ?? IndexPath(row: 0, section: 0)) as? TeacherOrGroupLoadingTableViewCell {
            cell.activityIndicator.stopAndHide()
        }
        
        let alert = UIAlertController(title: "Помилка", message: localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (_) in
            
        }))
        alert.addAction(UIAlertAction(title: "Оновити", style: .default, handler: { (_) in
            switch alertCase {
            case .getGroupLessonsType:
                if let group = group, let indexPath = indexPath {
                    self.getGroupLessons(group: group, indexPath: indexPath)
                }
            case .getTeacherLessonsType:
                if let teacher = teacher, let indexPath = indexPath {
                    self.getTeacherLessons(teacher: teacher, indexPath: indexPath)
                }
            case .getAllGroupType:
                self.getAllGroups()
            case .getAllTeachersType:
                self.getAllTeachers()
            case .getTeachersOfGroupType:
                self.getTeachersOfGroup()
            }
        }))

        self.present(alert, animated: true, completion: nil)
    }

    func getTeachersOfGroup(isNeedToUpdate: Bool = false) {
        API.getTeachersOfGroup(forGroupWithId: settings.groupID).done({ [weak self] (teachers) in
            guard let this = self else { return }
            
            this.groupTeachers = teachers

            this.activityIndicator.stopAndHide()
            this.tableView.isHidden = false
            
            if this.teachers.isEmpty {
                this.segmentControl.selectedSegmentIndex = 0
                this.didSegmentControlChangeState(this.segmentControl ?? UISegmentedControl())
            }
            
            if isNeedToUpdate && this.segmentControl.selectedSegmentIndex == 0 {
                this.teachers = teachers
            }
            
            self?.tableView.reloadData()

        }).catch({ [weak self] (error) in
            self?.getDefaultErrorAlert(localizedDescription: error.localizedDescription, alertCase: .getTeachersOfGroupType, group: nil, teacher: nil, indexPath: nil)
        })
    }
    
    func getAllTeachers(isNeedToUpdate: Bool = false) {
        API.getAllTeachers().done({ [weak self] (teachers) in
            guard let this = self else { return }
            
            switch this.groupAndTeacherControllerType {
            case .isTeachersChooser:
                this.teachers = teachers
            case .isTeacherViewController:
                if this.settings.sheduleType == .teachers {
                    this.teachers = teachers
                }
            default:
                this.allTeachers = teachers
            }

            this.activityIndicator.stopAndHide()

            switch this.groupAndTeacherControllerType {
            case .isGroupChooser, .isTeachersChooser:
                if this.startWriteLabel.isHidden {
                    this.tableView.isHidden = false
                    this.updateSearchResults(for: this.search)
                } else {
                    this.tableView.isHidden = true
                }
            default:
                if isNeedToUpdate && this.segmentControl.selectedSegmentIndex == 1 {
                    this.teachers = teachers
                }
                this.tableView.isHidden = false
                
            }

            this.tableView.reloadData()
        }).catch({ [weak self] (error) in
            if self?.segmentControl.selectedSegmentIndex == 1 {
                self?.getDefaultErrorAlert(localizedDescription: error.localizedDescription, alertCase: .getAllTeachersType, group: nil, teacher: nil, indexPath: nil)
            }
        })
    }
    
    func getAllGroups() {
        API.getAllGroups().done({ [weak self] (groups) in
            guard let this = self else { return }
            this.groups = groups

            this.activityIndicator.stopAndHide()
            switch this.groupAndTeacherControllerType {
            case .isGroupChooser, .isTeachersChooser:
                if this.startWriteLabel.isHidden {
                    this.tableView.isHidden = false
                    this.updateSearchResults(for: this.search)
                } else {
                    this.tableView.isHidden = true
                }
            default:
                this.tableView.isHidden = false

            }
            
            this.tableView.reloadData()
        }).catch({ [weak self] (error) in
            self?.getDefaultErrorAlert(localizedDescription: error.localizedDescription, alertCase: .getAllGroupType, group: nil, teacher: nil, indexPath: nil)
        })
    }
    
    func getGroupLessons(group: Group, indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) as? TeacherOrGroupLoadingTableViewCell else { return }
        
        cell.activityIndicator.startAndShow()
        
        API.getStudentLessons(forGroupWithId: group.groupID).done({ [weak self] (lessons) in
            guard let this = self else { return }
            
            cell.activityIndicator.stopAndHide()

            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let sheduleVC : SheduleViewController = mainStoryboard.instantiateViewController(withIdentifier: SheduleViewController.identifier) as? SheduleViewController else { return }
            
            sheduleVC.isFromGroupsAndTeacherOrFavourite = true
            sheduleVC.selectedWeek = .first
            
            sheduleVC.lessonsFromSegue = lessons
            sheduleVC.groupFromSegue = group

            sheduleVC.navigationItem.title = group.groupFullName.uppercased()
            
            this.navigationController?.pushViewController(sheduleVC, animated: true)
            
        }).catch({ [weak self] (error) in
            guard let this = self else { return }

            if error.localizedDescription == NetworkingApiError.lessonsNotFound.localizedDescription {
                let alert = UIAlertController(title: nil, message: "Розкладу для цієї групи не існує", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Назад", style: .default, handler: { (_) in
                    this.navigationController?.popViewController(animated: true)
                }))
                
                this.present(alert, animated: true, completion: {
                    cell.activityIndicator.stopAndHide()
                })
            } else {
                self?.getDefaultErrorAlert(localizedDescription: error.localizedDescription, alertCase: .getGroupLessonsType, group: group, teacher: nil, indexPath: indexPath)
            }
        })
    }
    
    func getTeacherLessons(teacher: Teacher, indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) as? TeacherOrGroupLoadingTableViewCell else { return }
        cell.activityIndicator.startAndShow()
        
        API.getTeacherLessons(forTeacherWithId: teacher.teacherID).done({ [weak self] (lessons) in
            guard let this = self else { return }
            
            cell.activityIndicator.stopAndHide()
            
            guard let sheduleVC  = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: SheduleViewController.identifier) as? SheduleViewController else { return }
            
            sheduleVC.lessonsFromSegue = lessons
            sheduleVC.teacherFromSegue = teacher
            sheduleVC.isFromGroupsAndTeacherOrFavourite = true
            sheduleVC.isTeachersShedule = true
            
            this.navigationController?.pushViewController(sheduleVC, animated: true)

        }).catch({ [weak self] (error) in
            guard let this = self else { return }

            if error.localizedDescription == NetworkingApiError.lessonsNotFound.localizedDescription {
                let alert = UIAlertController(title: nil, message: "Розкладу для цього викладача не існує", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Назад", style: .default, handler: { (_) in
                }))
                
                this.present(alert, animated: true, completion: {
                    cell.activityIndicator.stopAndHide()
                })
            } else {
                this.getDefaultErrorAlert(localizedDescription: error.localizedDescription, alertCase: .getTeacherLessonsType, group: nil, teacher: teacher, indexPath: indexPath)
            }
        })
    }
    
}
