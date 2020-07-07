//
//  FavouriteViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 20.02.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit
import PromiseKit


class FavouriteViewController: UIViewController {

    /// Main tableView
    @IBOutlet weak var tableView: UITableView!
    
    /// Label which show "Цей список порожній..."
    @IBOutlet weak var emptyFavouritesLabel: UILabel!
    
    /// Section names
    let sectionNames: [String] = ["Групи", "Викладачі"]

    /// Favourites singleton
    let favourites = Favourites.shared

    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigation()
    }
    
    
    // MARK: - viewWillAppear
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
    
    
    // MARK: - SETUP functions
    
    private func setupNavigation() {
        setLargeTitleDisplayMode(.never)
        self.navigationController?.navigationBar.isTranslucent = true
        self.tabBarController?.tabBar.isTranslucent = true
    }
    
    
    private func setupTableView() {
        tableView.register(UINib(nibName: TeacherOrGroupLoadingTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: TeacherOrGroupLoadingTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = tint
    }
    

    /// Get teacher or group to show in `SheduleViewController`
    func getGroupOrTeacherLesson(group: Group?, teacher: Teacher?, indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) as? TeacherOrGroupLoadingTableViewCell else { return }
        
        cell.startLoadingCellIndicator()
        
        let isGroup = group != nil ? true : false
        let serverLessons: Promise<[Lesson]> = isGroup ? API.getStudentLessons(forGroupWithId: group?.groupID ?? 0) : API.getTeacherLessons(forTeacherWithId: teacher?.teacherID ?? 0)
        
        serverLessons.done({ [weak self] (lessons) in
            guard let this = self else { return }
            
            cell.stopLoadingCellIndicator()

            guard let sheduleVC: SheduleViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: SheduleViewController.identifier) as? SheduleViewController else { return }
            if isGroup {
                sheduleVC.isFromGroupsAndTeacherOrFavourite = true
                sheduleVC.lessonsFromSegue = lessons
                sheduleVC.groupFromSegue = group
                sheduleVC.navigationItem.title = group?.groupFullName.uppercased()
            } else {
                sheduleVC.isTeachersShedule = true
                sheduleVC.isFromGroupsAndTeacherOrFavourite = true
                sheduleVC.lessonsFromSegue = lessons
                sheduleVC.teacherFromSegue = teacher
            }
            this.navigationController?.pushViewController(sheduleVC, animated: true)
            
        }).catch({ [weak self] (error) in
            guard let this = self else { return }

            if error.localizedDescription == NetworkingApiError.lessonsNotFound.localizedDescription {
                let alert = UIAlertController(title: nil, message: "Розкладу для цієї групи не існує", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Назад", style: .default, handler: { (_) in
                    this.navigationController?.popViewController(animated: true)
                }))
                this.present(alert, animated: true, completion: {
                    cell.stopLoadingCellIndicator()
                })
            } else {
                let alert = UIAlertController(title: "Помилка", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Оновити", style: .default, handler: { (_) in
                    if isGroup {
                        this.getGroupOrTeacherLesson(group: group, teacher: nil, indexPath: indexPath)
                    } else {
                        this.getGroupOrTeacherLesson(group: nil, teacher: teacher, indexPath: indexPath)
                    }
                }))
                this.present(alert, animated: true, completion: nil)
            }
        })
        
    }
}


// MARK: - UITableViewDelegate + DataSource
extension FavouriteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNames.count
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? favourites.favouriteGroupsNames.count : favourites.favouriteTeachersNames.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TeacherOrGroupLoadingTableViewCell.identifier, for: indexPath) as? TeacherOrGroupLoadingTableViewCell else { return UITableViewCell() }
        
        cell.stopLoadingCellIndicator()
        
        cell.mainLabel.text = indexPath.section == 0 ? favourites.favouriteGroupsNames[indexPath.row] : favourites.favouriteTeachersNames[indexPath.row]
    
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let group = Group(groupID: favourites.favouriteGroupsID[indexPath.row], groupFullName: favourites.favouriteGroupsNames[indexPath.row], groupPrefix: "", groupOkr: .magister, groupType: .daily, groupURL: "")
            
            getGroupOrTeacherLesson(group: group, teacher: nil, indexPath: indexPath)
        } else {
            let teacher = Teacher(teacherID: favourites.favouriteTeachersID[indexPath.row], teacherURL: "", teacherName: favourites.favouriteTeachersNames[indexPath.row], teacherFullName: favourites.favouriteTeachersNames[indexPath.row], teacherShortName: "", teacherRating: "")
            getGroupOrTeacherLesson(group: nil, teacher: teacher, indexPath: indexPath)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = sectionColour
        return view
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        
        returnedView.backgroundColor = sectionColour

        let label = UILabel(frame: CGRect(x: 16, y: 3, width: view.frame.size.width, height: 25))
        label.text = sectionNames[section]

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
