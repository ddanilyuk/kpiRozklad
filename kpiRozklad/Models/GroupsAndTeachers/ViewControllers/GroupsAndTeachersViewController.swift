//
//  TeachersViewController.swift
//  kpiRozklad
//
//  Created by Denis on 26.10.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit



class GroupsAndTeachersViewController: UIViewController {
    
    
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
    
    
    func activityIndicatorStopAndHide() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    
    func activityIndicatorStartAndVisible() {
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
    
}


extension GroupsAndTeachersViewController: UITableViewDelegate, UITableViewDataSource {
    
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
