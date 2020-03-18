//
//  GroupsAndTeachersVC+ServerApi.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 18.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


extension GroupsAndTeachersViewController {
    // MARK: - server

    func serverGroupTeachers() {
        let stringURL = "https://api.rozklad.org.ua/v2/groups/\(Settings.shared.groupID)/teachers"
        guard let url = URL(string: stringURL) else { return }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()

            do {
                guard let serverFULLDATA = try? decoder.decode(WelcomeTeachers.self, from: data) else { return }
                self.groupTeachers = serverFULLDATA.data
                
                DispatchQueue.main.async {
                    self.activityIndicatorStopAndHide()
                    
                    self.tableView.isHidden = false
                    
                    self.segmentControl.selectedSegmentIndex = 0
                    self.didSegmentControlChangeState(self.segmentControl)
                    
//                    self.teachers = self.groupTeachers
                    self.tableView.reloadData()

                }
            }
        }
        task.resume()
    }
    
    
    /// Functon which getting data from server
    func serverAllTeachersOrGroups(requestType: SheduleType) {
        let decoder = JSONDecoder()
        
        var stringURL = ""
        
        if requestType == .groups {
            stringURL = "https://api.rozklad.org.ua/v2/groups/?filter=%7B'showAll':true%7D"
        } else if requestType == .teachers {
            stringURL = "https://api.rozklad.org.ua/v2/teachers/?filter=%7B'showAll':true%7D"
        }
        
        guard let url = URL(string: stringURL) else { return }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            do {
                if requestType == .groups {
                    guard let serverFULLDATA = try? decoder.decode(WelcomeGroup.self, from: data) else { return }
                    
                    self.groups = serverFULLDATA.data
                    
                } else if requestType == .teachers {
                    guard let serverFULLDATA = try? decoder.decode(WelcomeTeachers.self, from: data) else { return }
                    
                    if self.isSheduleTeachersChooser || (self.isTeacherViewController && global.sheduleType == .teachers) {
                        self.teachers = serverFULLDATA.data
                    } else {

                        self.allTeachers = serverFULLDATA.data
                    }
                }
                DispatchQueue.main.async {
                    self.activityIndicatorStopAndHide()
                    
                    if self.isSheduleGroupChooser || self.isSheduleTeachersChooser {
                        self.tableView.isHidden = true
                    } else {
                        self.tableView.isHidden = false
                    }
                    
                    self.tableView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    
    func serverGetChoosenGroupShedule(group: Group, indexPath: IndexPath) {
        guard let url = URL(string: "https://api.rozklad.org.ua/v2/groups/\(String(group.groupID))/lessons") else { return }
        
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: indexPath) as? TeacherOrGroupLoadingTableViewCell {
                cell.activityIndicator.isHidden = false
                cell.activityIndicator.startAnimating()
            }
        }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()

            do {
                
                DispatchQueue.main.async {
                    guard let cell = self.tableView.cellForRow(at: indexPath) as? TeacherOrGroupLoadingTableViewCell else {
                        return
                    }
                    if let error = try? decoder.decode(Error.self, from: data) {
                        if error.message == "Lessons not found" {
                            
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: nil, message: "Розкладу для цієї групи не існує", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Назад", style: .default, handler: { (_) in
                                    self.navigationController?.popViewController(animated: true)
                                }))
                                
                                self.present(alert, animated: true, completion: {
                                    cell.activityIndicator.isHidden = true
                                    cell.activityIndicator.stopAnimating()
                                })
                            }
                        }
                    }
                    
                    guard let serverFULLDATA = try? decoder.decode(WelcomeLessons.self, from: data) else { return }
                    
                    cell.activityIndicator.isHidden = true
                    cell.activityIndicator.stopAnimating()

                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    guard let sheduleVC : SheduleViewController = mainStoryboard.instantiateViewController(withIdentifier: SheduleViewController.identifier) as? SheduleViewController else { return }
                    
                    sheduleVC.isFromGroups = true
                    sheduleVC.currentWeek = 1
                    
                    sheduleVC.lessonsFromServer = serverFULLDATA.data
                    
                    sheduleVC.navigationController?.navigationItem.largeTitleDisplayMode = .never
                    sheduleVC.navigationController?.navigationBar.prefersLargeTitles = false
                    sheduleVC.navigationItem.largeTitleDisplayMode = .never
                    sheduleVC.navigationItem.title = group.groupFullName.uppercased()
                    
                    sheduleVC.group = group
                    
                    self.navigationController?.pushViewController(sheduleVC, animated: true)
                }
            }
        }
        task.resume()
    }
    
    func serverGetChoosenTeacherShedule(teacher: Teacher, indexPath: IndexPath) {
        guard var url = URL(string: "https://api.rozklad.org.ua/v2/teachers/") else { return }
        url.appendPathComponent(teacher.teacherID )
        url.appendPathComponent("/lessons")
//
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: indexPath) as? TeacherOrGroupLoadingTableViewCell {
                cell.activityIndicator.isHidden = false
                cell.activityIndicator.startAnimating()
            }
        }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()

            do {
                DispatchQueue.main.async {
                    guard let cell = self.tableView.cellForRow(at: indexPath) as? TeacherOrGroupLoadingTableViewCell else { return }
                    if let error = try? decoder.decode(Error.self, from: data) {
                        if error.message == "Lessons not found" {
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: nil, message: "Розкладу для цього викладача не існує", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Назад", style: .default, handler: { (_) in
                                    self.navigationController?.popViewController(animated: true)
                                }))
                                
                                self.present(alert, animated: true, completion: {
                                    cell.activityIndicator.isHidden = true
                                    cell.activityIndicator.stopAnimating()
                                })
                            }
                        }
                    }
                    
                    guard let serverFULLDATA = try? decoder.decode(WelcomeLessons.self, from: data) else { return }
                    
                    cell.activityIndicator.isHidden = true
                    cell.activityIndicator.stopAnimating()

                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    guard let teacherSheduleVC  = mainStoryboard.instantiateViewController(withIdentifier: TeacherSheduleViewController.identifier) as? TeacherSheduleViewController else { return }
                    
                    teacherSheduleVC.lessonsFromServer = serverFULLDATA.data
                    
                    teacherSheduleVC.isFromTeachersVC = true
                    
                    teacherSheduleVC.teacher = teacher
                    
                    self.navigationController?.pushViewController(teacherSheduleVC, animated: true)

                }
                
            }
            
        }
        
        task.resume()
        
    }
}
