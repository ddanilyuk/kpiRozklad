//
//  FavouriteViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 20.02.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit



class FavouriteViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let favourites = Favourites.shared
    
    @IBOutlet weak var emptyFavouritesLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigation()
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
    
    
    private func setupNavigation() {
        setLargeTitleDisplayMode(.never)
        self.navigationController?.navigationBar.isTranslucent = true
        self.tabBarController?.tabBar.isTranslucent = true
    }
    
    
    private func setupTableView() {
        tableView.register(UINib(nibName: TeacherOrGroupLoadingTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: TeacherOrGroupLoadingTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = tint
        } else {
            tableView.backgroundColor = .white
        }
    }
    
    
//    func serverGroupShedule(group: Group, indexPath: IndexPath) {
//        guard let url = URL(string: "https://api.rozklad.org.ua/v2/groups/\(String(group.groupID))/lessons") else { return }
//
//        DispatchQueue.main.async {
//            if let cell = self.tableView.cellForRow(at: indexPath) as? TeacherOrGroupLoadingTableViewCell {
//                cell.activityIndicator.isHidden = false
//                cell.activityIndicator.startAnimating()
//            }
//        }
//
//        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
//            guard let data = data else { return }
//            let decoder = JSONDecoder()
//
//            do {
//                DispatchQueue.main.async {
//                    guard let serverFULLDATA = try? decoder.decode(WelcomeLessons.self, from: data) else { return }
//
//                    if let cell = self.tableView.cellForRow(at: indexPath) as? TeacherOrGroupLoadingTableViewCell {
//                        cell.activityIndicator.isHidden = true
//                        cell.activityIndicator.stopAnimating()
//                    }
//
//                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//                    guard let sheduleVC : SheduleViewController = mainStoryboard.instantiateViewController(withIdentifier: SheduleViewController.identifier) as? SheduleViewController else { return }
//
//                    sheduleVC.isFromGroups = true
//                    sheduleVC.currentWeek = 1
//
//                    sheduleVC.lessonsFromServer = serverFULLDATA.data
//
////                    sheduleVC.navigationController?.navigationItem.largeTitleDisplayMode = .never
////                    sheduleVC.navigationController?.navigationBar.prefersLargeTitles = false
////                    sheduleVC.navigationItem.largeTitleDisplayMode = .never
//                    sheduleVC.navigationItem.title = group.groupFullName.uppercased()
//
//                    sheduleVC.group = group
//
//                    self.navigationController?.pushViewController(sheduleVC, animated: true)
//                }
//            }
//        }
//        task.resume()
//    }
    
    
    
    func getGroupLessons(group: Group, indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) as? TeacherOrGroupLoadingTableViewCell else { return }
        DispatchQueue.main.async {
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
        }
        
        API.getStudentLessons(forGroupWithId: group.groupID).done({ [weak self] (lessons) in
            guard let this = self else { return }
            
            cell.activityIndicator.isHidden = true
            cell.activityIndicator.stopAnimating()

            guard let sheduleVC: SheduleViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: SheduleViewController.identifier) as? SheduleViewController else { return }
            
            sheduleVC.isFromGroupsAndTeacherOrFavourite = true
//            sheduleVC.currentWeek = 1
            
            sheduleVC.lessonsFromSegue = lessons
//            getCurrentAndNextLesson(lessons: [Lesson], timeIsNowString: <#T##String#>, dayNumberFromCurrentDate: <#T##Int#>, currentWeekFromTodayDate: <#T##Int#>)
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
                    cell.activityIndicator.isHidden = true
                    cell.activityIndicator.stopAnimating()
                })
            } else {
                let alert = UIAlertController(title: "Помилка", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (_) in
                    
                }))
                alert.addAction(UIAlertAction(title: "Оновити", style: .default, handler: { (_) in
                    this.getGroupLessons(group: group, indexPath: indexPath)
                }))

                this.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    
    func getTeacherLessons(teacher: Teacher, indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) as? TeacherOrGroupLoadingTableViewCell else { return }
        DispatchQueue.main.async {
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
        }
        
        API.getTeacherLessons(forTeacherWithId: Int(teacher.teacherID) ?? 0).done({ [weak self] (lessons) in
            guard let this = self else { return }
            
            cell.activityIndicator.isHidden = true
            cell.activityIndicator.stopAnimating()

            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let teacherSheduleVC  = mainStoryboard.instantiateViewController(withIdentifier: TeacherSheduleViewController.identifier) as? TeacherSheduleViewController else { return }
            
            teacherSheduleVC.lessonsFromSegue = lessons
            
            teacherSheduleVC.isFromTeachersVC = true
            
            teacherSheduleVC.teacher = teacher
            
            this.navigationController?.pushViewController(teacherSheduleVC, animated: true)

        }).catch({ [weak self] (error) in
            guard let this = self else { return }

            if error.localizedDescription == NetworkingApiError.lessonsNotFound.localizedDescription {
                let alert = UIAlertController(title: nil, message: "Розкладу для цього викладача не існує", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Назад", style: .default, handler: { (_) in
                }))
                
                this.present(alert, animated: true, completion: {
                    cell.activityIndicator.isHidden = true
                    cell.activityIndicator.stopAnimating()
                })
            } else {
                let alert = UIAlertController(title: "Помилка", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (_) in
                    
                }))
                alert.addAction(UIAlertAction(title: "Оновити", style: .default, handler: { (_) in
                    this.getTeacherLessons(teacher: teacher, indexPath: indexPath)
                }))

                this.present(alert, animated: true, completion: nil)
            }
        })
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
            let group = Group(groupID: favourites.favouriteGroupsID[indexPath.row], groupFullName: favourites.favouriteGroupsNames[indexPath.row], groupPrefix: "", groupOkr: .magister, groupType: .daily, groupURL: "")
            
            getGroupLessons(group: group, indexPath: indexPath)
        } else {
            let teacher = Teacher(teacherID: String(favourites.favouriteTeachersID[indexPath.row]), teacherName: favourites.favouriteTeachersNames[indexPath.row], teacherFullName: favourites.favouriteTeachersNames[indexPath.row], teacherShortName: "", teacherURL: "", teacherRating: "")
            getTeacherLessons(teacher: teacher, indexPath: indexPath)
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
