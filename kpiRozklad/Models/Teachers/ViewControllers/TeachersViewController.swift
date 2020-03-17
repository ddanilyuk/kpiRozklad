//
//  TeachersViewController.swift
//  kpiRozklad
//
//  Created by Denis on 26.10.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

enum SheduleType {
    case groups
    case teachers
}

class TeachersViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let reuseID = "reuseIDForTeachers"
    
    var teachers: [Teacher] = []
    var teachersInSearch: [Teacher] = []
    
    /// **Main** variable, show when `isSearching == false`
    var groups: [Group] = []
    
    /// Variable, show when `isSearching == true`
    var groupsInSearch: [Group] = []

    var groupTeachers: [Teacher] = []
    
    var allTeachers: [Teacher] = []


    var isSearching = false
    let search = UISearchController(searchResultsController: nil)
    

    let settings = Settings.shared

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var startWriteLabel: UILabel!
    
    
    // If choosing group for shedule (to Shedule VC) if global.sheduleType == .group
    var isSheduleGroupChooser: Bool = false
    
    // If choosing teachers for shedule (to Shedule VC) if global.sheduleType == .teachers
    var isSheduleTeachersChooser: Bool = false
    
    var isGroupViewController: Bool = false
    
    var isTeacherViewController: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getVariablesFromNavigationController()
        
        if isSheduleTeachersChooser == false && isSheduleGroupChooser == false && isGroupViewController == false {
            isTeacherViewController = true
        }
        
        setupActivityIndicator()

        setupTableView()

        setupNavigationAndSearch()

        print("isSheduleGroupChooser", isSheduleGroupChooser)
        print("isSheduleTeachersChooser", isSheduleTeachersChooser)
        print("isGroupViewController", isGroupViewController)
        print("isTeacherViewController", isTeacherViewController)

        
        if isSheduleTeachersChooser {
            
            disableSegmentControl()
            serverAllTeachersOrGroups(requestType: .teachers)
            
        } else if isSheduleGroupChooser {
            
            disableSegmentControl()
            serverAllTeachersOrGroups(requestType: .groups)
            
        } else if isGroupViewController {
            
            showWithoutStartWriteLabel()
            disableSegmentControl()
            serverAllTeachersOrGroups(requestType: .groups)
            
        } else if isTeacherViewController && global.sheduleType == .teachers {
            
            showWithoutStartWriteLabel()
            disableSegmentControl()
            serverAllTeachersOrGroups(requestType: .teachers)
            
        } else if isTeacherViewController && global.sheduleType == .groups {
            
            showWithoutStartWriteLabel()
            serverGroupTeachers()
            serverAllTeachersOrGroups(requestType: .teachers)
            
        }
        
    }
    
    private func showWithoutStartWriteLabel() {
        tableView.isHidden = true
        startWriteLabel.isHidden = true
        activityIndicatorStartAndVisible()
    }
    
    private func disableSegmentControl() {
        segmentControl.selectedSegmentIndex = 1
        didSegmentControlChangeState(segmentControl)
        segmentControl.isHidden = true
    }
    
    
    private func activityIndicatorStopAndHide() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func activityIndicatorStartAndVisible() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }
    
    private func getVariablesFromNavigationController() {
        guard let groupNavigationController = self.navigationController as? TeachersNavigationController else { return }
        
        isSheduleGroupChooser = groupNavigationController.isSheduleGroupChooser
        isSheduleTeachersChooser = groupNavigationController.isSheduleTeachersChooser
        isTeacherViewController = groupNavigationController.isTeacherViewController
    }
    
    
    private func setupActivityIndicator() {
        activityIndicator.stopAnimating()
        tableView.isHidden = true
        activityIndicator.isHidden = true
        self.view.bringSubviewToFront(activityIndicator)
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: TeacherOrGroupLoadingTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: TeacherOrGroupLoadingTableViewCell.identifier)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = tableViewBackground
        self.view.backgroundColor = tableViewBackground

    }
    
    private func setupNavigationAndSearch() {
        
        
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        // Search bar settings
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        
        if isSheduleTeachersChooser || isTeacherViewController {
            // If choosing teachers show this titles
            search.searchBar.placeholder = "Пошук викладача"
            self.title = "Викладачі"
            startWriteLabel.text = " Почніть вводити ініціали"
        } else {
            search.searchBar.placeholder = "Пошук групи"
            self.title = "Групи"
            startWriteLabel.text = " Почніть вводити назву групи"
        }
        
        self.navigationItem.searchController = search
        self.navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    
    @IBAction func didSegmentControlChangeState(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
            case 0:
                self.teachers = []
                tableView.reloadData()
                
                teachers = groupTeachers

                tableView.reloadData()
            case 1:
                self.allTeachers = self.allTeachers.sorted{Int($0.teacherID) ?? 0 < Int($1.teacherID) ?? 0}
                self.teachers = []
                tableView.reloadData()

                teachers = allTeachers

                tableView.reloadData()
            default:
                break
        }
    }
    
    
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
    
    
    // MARK: - server
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
                    print(url)
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
    
    // MARK: - server
    func serverGetChoosenTeacherShedule(teacher: Teacher, indexPath: IndexPath) {
        guard var url = URL(string: "https://api.rozklad.org.ua/v2/teachers/") else { return }
        url.appendPathComponent(teacher.teacherID )
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


extension TeachersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSheduleTeachersChooser || isTeacherViewController {
            if isSearching {
                return teachersInSearch.count
            } else {
                return teachers.count
            }
        } else {
            if isSearching {
                return groupsInSearch.count
            } else {
                return groups.count
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TeacherOrGroupLoadingTableViewCell.identifier, for: indexPath) as? TeacherOrGroupLoadingTableViewCell else { return UITableViewCell() }
        
        cell.activityIndicator.isHidden = true
        
        if isSheduleTeachersChooser || isTeacherViewController {
            cell.mainLabel.text = isSearching ? teachersInSearch[indexPath.row].teacherName : teachers[indexPath.row].teacherName
        } else {
            cell.mainLabel.text = isSearching ? groupsInSearch[indexPath.row].groupFullName : groups[indexPath.row].groupFullName
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTeacherSheduleFromAllTeachers" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let destination = segue.destination as? TeacherSheduleViewController {
                    if isSearching {
                        destination.teacher = teachersInSearch[indexPath.row]
                    } else {
                        destination.teacher = teachers[indexPath.row]
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let window = appDelegate?.window else { return }
        
        
        if isSheduleTeachersChooser {
            
            let teacher = isSearching ? teachersInSearch[indexPath.row] : teachers[indexPath.row]
            
            settings.groupName = ""
            settings.groupID = 0
            
            settings.teacherName = teacher.teacherName
            settings.teacherID = Int(teacher.teacherID) ?? 0
            
            settings.isTryToRefreshShedule = true

            guard let mainTabBar : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as? UITabBarController else { return }
            
            self.dismiss(animated: true, completion: {
                window.rootViewController = mainTabBar
            })
        } else if isSheduleGroupChooser {
            let group = isSearching ? groupsInSearch[indexPath.row] : groups[indexPath.row]

            settings.groupName = group.groupFullName
            settings.groupID = group.groupID
            
            settings.teacherName = ""
            settings.teacherID = 0
            
            settings.isTryToRefreshShedule = true

            guard let mainTabBar : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as? UITabBarController else { return }

            self.dismiss(animated: true, completion: {
                window.rootViewController = mainTabBar
            })
        } else if isGroupViewController {
            let group = isSearching ? groupsInSearch[indexPath.row] : groups[indexPath.row]
            serverGetChoosenGroupShedule(group: group, indexPath: indexPath)
        } else if isTeacherViewController {
            
            let teacher = isSearching ? teachersInSearch[indexPath.row] : teachers[indexPath.row]
            serverGetChoosenTeacherShedule(teacher: teacher, indexPath: indexPath)
            
//            guard (storyboard?.instantiateViewController(withIdentifier: "TeacherSheduleViewController") as? TeacherSheduleViewController) != nil else { return }
//            performSegue(withIdentifier: "showTeacherSheduleFromAllTeachers", sender: self)
        }
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let view = UIView()
//        view.backgroundColor = sectionColour
//
//        return view
//    }
}


//Mark: - extencions for search
extension TeachersViewController: UISearchResultsUpdating {

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
                serverAllTeachersOrGroups(requestType: .teachers)
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
                serverAllTeachersOrGroups(requestType: .groups)
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
