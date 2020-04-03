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
    
    /// Settings singleton
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
        
        stopLoading()
        tableView.isHidden = true

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
    
    /// When need to show  `tableView` now
    private func showWithoutStartWriteLabel() {
        tableView.isHidden = true
        startWriteLabel.isHidden = true
        startLoading()
    }
    
    /// Disable  `segmentControl` which change fom "Мої" and "Всі"
    private func disableSegmentControl() {
        segmentControl.selectedSegmentIndex = 1
        didSegmentControlChangeState(segmentControl)
        segmentControl.isHidden = true
    }
    
    /// Stop Loading
    func stopLoading() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    
    /// Start Loading
    func startLoading() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        self.view.bringSubviewToFront(activityIndicator)
    }
    
    
    /// Get All vaiables from `navigationController`
    private func getVariablesFromNavigationController() {
        guard let groupNavigationController = self.navigationController as? TeachersNavigationController else { return }
        
        isSheduleGroupChooser = groupNavigationController.isSheduleGroupChooser
        isSheduleTeachersChooser = groupNavigationController.isSheduleTeachersChooser
        isTeacherViewController = groupNavigationController.isTeacherViewController
        
        if isSheduleTeachersChooser == false && isSheduleGroupChooser == false && isGroupViewController == false {
            isTeacherViewController = true
        }
    }
    
    
    // MARK: - SETUP functions
    
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
    
    
    /// Change`segmentControl` state
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
