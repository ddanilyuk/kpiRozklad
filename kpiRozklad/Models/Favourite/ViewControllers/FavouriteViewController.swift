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
    
    @IBOutlet weak var emptyFavouritesLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        
        if favourites.favouriteGroupsNames.count == 0 && favourites.favouriteTeachersNames.count == 0 {
            tableView.isHidden = true
            emptyFavouritesLabel.isHidden = false
            self.view.backgroundColor = tableViewBackground
            
        } else {
            tableView.isHidden = false
            emptyFavouritesLabel.isHidden = true
        }

    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: TeacherOrGroupLoadingTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: TeacherOrGroupLoadingTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = sectionColour

    }
    
    
    func serverGroupShedule(group: Group, indexPath: IndexPath) {
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
                    guard let serverFULLDATA = try? decoder.decode(WelcomeLessons.self, from: data) else { return }
                    
                    if let cell = self.tableView.cellForRow(at: indexPath) as? TeacherOrGroupLoadingTableViewCell {
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
        url.appendPathComponent(teacher.teacherID)
        url.appendPathComponent("/lessons")
        print(url)
        
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
                    guard let serverFULLDATA = try? decoder.decode(WelcomeLessons.self, from: data) else { return }
                    
                    if let cell = self.tableView.cellForRow(at: indexPath) as? TeacherOrGroupLoadingTableViewCell {
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TeacherOrGroupLoadingTableViewCell.identifier, for: indexPath) as? TeacherOrGroupLoadingTableViewCell else { return UITableViewCell() }
        

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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    //        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        let view = UIView()
        view.backgroundColor = sectionColour
//        view.backgroundColor = tint
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let array: [String] = ["Групи", "Викладачі"]
        
        
        returnedView.backgroundColor = sectionColour

        let label = UILabel(frame: CGRect(x: 16, y: 3, width: view.frame.size.width, height: 25))
        label.text = array[section]

        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        returnedView.addSubview(label)

        return returnedView
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Видалити") { action, index in
            if index.section == 0 {
                _ = self.favourites.favouriteGroupsNames.remove(at: index.row)
                _ = self.favourites.favouriteGroupsID.remove(at: index.row)
            } else if index.section == 1 {
                _ = self.favourites.favouriteTeachersID.remove(at: index.row)
                _ = self.favourites.favouriteTeachersNames.remove(at: index.row)
            }
            
            tableView.deleteRows(at: [index], with: .fade)
            if self.favourites.favouriteGroupsNames.count == 0 &&  self.favourites.favouriteTeachersNames.count == 0 {
                self.tableView.isHidden = true
                self.emptyFavouritesLabel.isHidden = false
                self.view.backgroundColor = sectionColour
            }

        }

        return [delete]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
