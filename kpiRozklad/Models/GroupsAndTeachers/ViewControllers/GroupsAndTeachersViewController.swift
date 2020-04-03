//
//  TeachersViewController.swift
//  kpiRozklad
//
//  Created by Denis on 26.10.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit


class GroupsAndTeachersViewController: UIViewController {
    
    /// Main table view
    @IBOutlet weak var tableView: UITableView!
    
    /// Variable to show teachers when `!isSearching`
    var teachers: [Teacher] = []
    
    /// Variable to show teachers when `isSearching`
    var teachersInSearch: [Teacher] = []
    
    /// Variable to show groups when `!isSearching`
    var groups: [Group] = []
    
    /// Variable to show groups when `isSearching`
    var groupsInSearch: [Group] = []

    /**
     Teachers which teach in group
     */
    var groupTeachers: [Teacher] = []
    
    /**
     All teachers
     */
    var allTeachers: [Teacher] = []

    /// Searching
    var isSearching = false
    let search = UISearchController(searchResultsController: nil)
    
    /// Main activity indicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// Segment control that change `groupTeachers` and `allTeachers`
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    /// Label with "Почніть вводити ..."
    @IBOutlet weak var startWriteLabel: UILabel!
    
    let settings = Settings.shared

    
    /// If choosing group for shedule (to Shedule VC) if global.sheduleType == .group
    var isSheduleGroupChooser: Bool = false
    
    /// If choosing teachers for shedule (to Shedule VC) if global.sheduleType == .teachers
    var isSheduleTeachersChooser: Bool = false
    
    /// Show groups (`allTeachers` and `groupTeachers`)
    var isGroupViewController: Bool = false
    
    /// Show teachers `teachers`
    var isTeacherViewController: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Initial setup
        
        getVariablesFromNavigationController()
        
        setupActivityIndicator()

        setupTableView()

        setupNavigationAndSearch()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        /// If groups or teachers is empty, make request again
        if (groups.count == 0 && (isSheduleGroupChooser || isGroupViewController)) ||
           (teachers.count == 0 && (isSheduleTeachersChooser || isTeacherViewController)) {
            
            if isSheduleTeachersChooser {
                disableSegmentControl()
                getAllTeachers()
            } else if isSheduleGroupChooser {
                disableSegmentControl()
                getAllGroups()
            } else if isGroupViewController {
                showWithoutStartWriteLabel()
                disableSegmentControl()
                getAllGroups()
            } else if isTeacherViewController && global.sheduleType == .teachers {
                showWithoutStartWriteLabel()
                disableSegmentControl()
                getAllTeachers()
            } else if isTeacherViewController && global.sheduleType == .groups {
                showWithoutStartWriteLabel()
                getTeachersOfGroup()
                getAllTeachers()
            }
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
        
        if isSheduleTeachersChooser == false && isSheduleGroupChooser == false && isGroupViewController == false {
            isTeacherViewController = true
        }
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
        tableView.backgroundColor = tint
    }
    
    
    private func setupNavigationAndSearch() {
        /// Search bar settings
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        
        setLargeTitleDisplayMode(.never)
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

        self.navigationController?.navigationBar.isTranslucent = true
        self.tabBarController?.tabBar.isTranslucent = true
    }
    
    
    @IBAction func didSegmentControlChangeState(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
            case 0:
                self.teachers = []
                
                if groupTeachers.count == 0 {
                    activityIndicator.startAnimating()
                    getTeachersOfGroup(isNeedToUpdate: true)
                }
                
                teachers = groupTeachers
                tableView.reloadData()
            case 1:
                self.teachers = []
                
                if allTeachers.count == 0 {
                    activityIndicator.startAnimating()
                    getAllTeachers(isNeedToUpdate: true)
                }

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
        

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let window = appDelegate?.window else { return }
        guard let mainTabBar: UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as? UITabBarController else { return }
        
        if isSheduleTeachersChooser {
            let teacher = isSearching ? teachersInSearch[indexPath.row] : teachers[indexPath.row]
            
            settings.teacherName = teacher.teacherName
            settings.teacherID = Int(teacher.teacherID) ?? 0
            
            settings.isTryToRefreshShedule = true
            
            if #available(iOS 13, *) {
                self.dismiss(animated: true, completion: {
                    window.rootViewController = mainTabBar
                })
            } else {
                window.rootViewController = mainTabBar
                window.makeKeyAndVisible()
            }
            
        } else if isSheduleGroupChooser {
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

        } else if isGroupViewController {
            let group = isSearching ? groupsInSearch[indexPath.row] : groups[indexPath.row]
            getGroupLessons(group: group, indexPath: indexPath)
        } else if isTeacherViewController {
            let teacher = isSearching ? teachersInSearch[indexPath.row] : teachers[indexPath.row]
            getTeacherLessons(teacher: teacher, indexPath: indexPath)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
