//
//  FavouriteViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 20.02.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

enum typeFavourite {
    case group
    case teacher
}

class FavouriteViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let favourites = Favourites.shared
    
//    var favouritesList: [(name: String, id: Int, type: typeFavourite)] = []
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        setFavouritesList()
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: ServerGetTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ServerGetTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
//    func setFavouritesList() {
//        favouritesList = []
//        let favouriteGroupsNames = favourites.favouriteGroupsNames
//        let favouriteGroupsID = favourites.favouriteGroupsID
//
//        let favouriteTeachersNames = favourites.favouriteTeachersNames
//        let favouriteTeachersID = favourites.favouriteTeachersID
//
//
//        for i in 0..<favourites.favouriteGroupsNames.count {
//            favouritesList.append((name: favouriteGroupsNames[i], id: favouriteGroupsID[i], .group))
//        }
//
//        for i in 0..<favourites.favouriteTeachersNames.count {
//            favouritesList.append((name: favouriteTeachersNames[i], id: favouriteTeachersID[i], .teacher))
//        }
//    }
    
    func serverGroupShedule(group: Group, indexPath: IndexPath) {
        guard let url = URL(string: "https://api.rozklad.org.ua/v2/groups/\(String(group.groupID))/lessons") else { return }
        print(url)
        
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: indexPath) as? ServerGetTableViewCell {
                cell.activityIndicator.isHidden = false
                cell.activityIndicator.startAnimating()
            }
        }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()

            do {
                DispatchQueue.main.async {
                    guard let serverFULLDATA = try? decoder.decode(WelcomeLessons.self, from: data) else { return }
                    
                    if let cell = self.tableView.cellForRow(at: indexPath) as? ServerGetTableViewCell {
                        cell.activityIndicator.isHidden = true
                        cell.activityIndicator.stopAnimating()
                    }

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
    
    
    func serverTeacherShedule(teacher: Teacher, indexPath: IndexPath) {
        guard var url = URL(string: "https://api.rozklad.org.ua/v2/teachers/") else { return }
        url.appendPathComponent(teacher.teacherID ?? "")
        url.appendPathComponent("/lessons")
        print(url)
        
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: indexPath) as? ServerGetTableViewCell {
                cell.activityIndicator.isHidden = false
                cell.activityIndicator.startAnimating()
            }
        }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()

            do {
                DispatchQueue.main.async {
                    guard let serverFULLDATA = try? decoder.decode(WelcomeLessons.self, from: data) else { return }
                    
                    if let cell = self.tableView.cellForRow(at: indexPath) as? ServerGetTableViewCell {
                        cell.activityIndicator.isHidden = true
                        cell.activityIndicator.stopAnimating()
                    }

                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    guard let sheduleVC : TeacherSheduleViewController = mainStoryboard.instantiateViewController(withIdentifier: TeacherSheduleViewController.identifier) as? TeacherSheduleViewController else { return }
                    
                    sheduleVC.isFromFavourites = true
                    sheduleVC.currentWeek = 1
                    
                    sheduleVC.lessonsFromServer = serverFULLDATA.data
                    
                    sheduleVC.navigationController?.navigationItem.largeTitleDisplayMode = .never
                    sheduleVC.navigationController?.navigationBar.prefersLargeTitles = false
                    sheduleVC.navigationItem.largeTitleDisplayMode = .never
//                    sheduleVC.navigationItem.title = group.groupFullName.uppercased()
                    
//                    Teacher(teacherID: <#T##String#>, teacherName: <#T##String#>, teacherFullName: <#T##String#>, teacherShortName: <#T##String#>, teacherURL: <#T##String#>, teacherRating: <#T##String#>)
                    sheduleVC.teacher = teacher
                    
                    self.navigationController?.pushViewController(sheduleVC, animated: true)
                }
            }
        }
        task.resume()
    }
    
}

extension FavouriteViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Групи", "Викладачі"][section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return favourites.favouriteGroupsNames.count
        } else {
            return favourites.favouriteTeachersNames.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServerGetTableViewCell.identifier, for: indexPath) as? ServerGetTableViewCell else { return UITableViewCell() }
        
//        var groups: [(name: String, id: Int)] = []
//        var teachers: [(name: String, id: Int)] = []
//
//        for favourite in favouritesList {
//            if favourite.type == .group {
//                groups.append((name: favourite.name, id: favourite.id))
//            } else if favourite.type == .teacher {
//                teachers.append((name: favourite.name, id: favourite.id))
//            }
//        }
        cell.activityIndicator.isHidden = true

        if indexPath.section == 0 {
            cell.mainLabel.text = favourites.favouriteGroupsNames[indexPath.row]
        } else {
            cell.mainLabel.text = favourites.favouriteTeachersNames[indexPath.row]
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
//            let favouriteChoosen = favourites.favouriteTeachersNames[indexPath.row]
            let group = Group(groupID: favourites.favouriteGroupsID[indexPath.row], groupFullName: favourites.favouriteGroupsNames[indexPath.row], groupPrefix: "", groupOkr: .magister, groupType: .daily, groupURL: "")
            
            serverGroupShedule(group: group, indexPath: indexPath)
        } else {
            let teacher = Teacher(teacherID: String(favourites.favouriteTeachersID[indexPath.row]), teacherName: favourites.favouriteTeachersNames[indexPath.row], teacherFullName: favourites.favouriteTeachersNames[indexPath.row], teacherShortName: "", teacherURL: "", teacherRating: "")
            serverTeacherShedule(teacher: teacher, indexPath: indexPath)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
