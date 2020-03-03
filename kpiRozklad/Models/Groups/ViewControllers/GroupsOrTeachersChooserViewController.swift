//
//  GroupsViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 20.02.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

//enum SheduleType {
//    case groups
//    case teachers
//}

class GroupsOrTeachersChooserViewController: UIViewController {

    /// groupReuseID
    let groupReuseID = "groupReuseID"
    
    /// is searching groups
    var isSearching = false
    
    /// **Main** variable, show when `isSearching == false`
    var groups: [Group] = []
    
    /// Variable, show when `isSearching == true`
    var groupsInSearch: [Group] = []
    
    var teachers: [Teacher] = []
    
    var teachersInSearch: [Teacher] = []

    /// Search Controller
    let search = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var startWritingLabel: UILabel!
    
    @IBOutlet weak var startWritingLabelHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // If choosing group for shedule (to Shedule VC) if global.sheduleType == .group
    var isSheduleGroupChooser: Bool = false
    
    // If choosing teachers for shedule (to Shedule VC) if global.sheduleType == .teachers
    var isSheduleTeachersChooser: Bool = false
    
    let settings = Settings.shared
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        setupActivityIndicator()
        
        getVariablesFromNavigationController()
//        requestTypeChoosen = .groups
        let type: SheduleType = isSheduleTeachersChooser ? .teachers : .groups
        serverAllTeaachetOrGroups(requestType: type)
        
        setupSearchAndNavigation()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: ServerGetTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ServerGetTableViewCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        startWritingLabel.isHidden = false
        tableView.isHidden = true
    }
    
    private func getVariablesFromNavigationController() {
        guard let groupNavigationController = self.navigationController as? MyNavigationController else {
            return
        }
        
        isSheduleGroupChooser = groupNavigationController.isSheduleGroupChooser
        isSheduleTeachersChooser = groupNavigationController.isSheduleTeachersChooser
    }
    
    
    private func setupSearchAndNavigation() {
        /// Search bar settings
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        
        if isSheduleTeachersChooser {
            // If choosing teachers show this titles
            search.searchBar.placeholder = "Пошук викладача"
            self.title = "Викладачі"
            startWritingLabel.text = " Почніть вводити ініціали"
        } else {
            search.searchBar.placeholder = "Пошук групи"
            self.title = "Групи"
            startWritingLabel.text = " Почніть вводити назву групи"
        }
        
        self.navigationItem.searchController = search
        self.navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    
    // MARK: - server
    /// Functon which getting data from server
    func serverAllTeaachetOrGroups(requestType: SheduleType) {
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
            print("in data")
            do {
                if requestType == .groups {
                    guard let serverFULLDATA = try? decoder.decode(WelcomeGroup.self, from: data) else { return }
                    
                    self.groups = serverFULLDATA.data
                    
                } else if requestType == .teachers {
                    guard let serverFULLDATA = try? decoder.decode(WelcomeTeachers.self, from: data) else { return }
                    
                    self.teachers = serverFULLDATA.data
                }
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.tableView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    
    func serverGetChoosenGroupShedule(group: Group, indexPath: IndexPath) {
        guard let url = URL(string: "https://api.rozklad.org.ua/v2/groups/\(String(group.groupID))/lessons") else { return }
        
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
    
    
}


// MARK: - Extencions For Table View
extension GroupsOrTeachersChooserViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSheduleTeachersChooser {
            if isSearching {
                return teachersInSearch.count
            } else {
                return teachersInSearch.count
            }
        } else {
            if isSearching {
                return groupsInSearch.count
            } else {
                return groups.count
            }
        }
    }
    
    // MARK: - cellForRowAt indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServerGetTableViewCell.identifier, for: indexPath) as? ServerGetTableViewCell else { return UITableViewCell() }
        
        cell.activityIndicator.isHidden = true
        
        if isSheduleTeachersChooser {
            cell.mainLabel.text = isSearching ? teachersInSearch[indexPath.row].teacherFullName : teachersInSearch[indexPath.row].teacherFullName
        } else {
            cell.mainLabel.text = isSearching ? groupsInSearch[indexPath.row].groupFullName : groups[indexPath.row].groupFullName
        }

        return cell
    }
    
    // MARK: - didSelectRowAt
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
        } else {
            let group = isSearching ? groupsInSearch[indexPath.row] : groups[indexPath.row]

            serverGetChoosenGroupShedule(group: group, indexPath: indexPath)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - Extencions For Search
extension GroupsOrTeachersChooserViewController: UISearchResultsUpdating {

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
            
            startWritingLabel.isHidden = false
            tableView.isHidden = true
            tableView.reloadData()
            return
        }
        
        if isSheduleTeachersChooser {
            isSearching = true
            teachersInSearch = []
            
            startWritingLabel.isHidden = true
            tableView.isHidden = false

            if teachers.count == 0 {
                tableView.isHidden = true
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                serverAllTeaachetOrGroups(requestType: .teachers)
            }
            
            for teacher in teachers {
                if teacher.teacherFullName.lowercased().contains(lowerCaseSearchText){
                    teachersInSearch.append(teacher)
                }
            }
            
        } else {
            isSearching = true
            groupsInSearch = []
            
            startWritingLabel.isHidden = true
            tableView.isHidden = false

            if groups.count == 0 {
                tableView.isHidden = true
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
                serverAllTeaachetOrGroups(requestType: .groups)
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

