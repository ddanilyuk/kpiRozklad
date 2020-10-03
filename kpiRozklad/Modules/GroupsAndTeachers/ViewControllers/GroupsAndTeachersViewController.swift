//
//  TeachersViewController.swift
//  kpiRozklad
//
//  Created by Denis on 26.10.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit


enum GroupAndTeacherControllerType {
    case isGroupChooser
    case isTeachersChooser
    case isGroupViewController
    case isTeacherViewController
}


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
    
    var groupAndTeacherControllerType: GroupAndTeacherControllerType = .isTeacherViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getVariablesFromNavigationController()
        
        activityIndicator.stopAndHide()
        tableView.isHidden = true

        setupTableView()
        
        setupSwitch()

        setupNavigationAndSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /// If groups or teachers is empty, make request again
        if (groups.count == 0 && (groupAndTeacherControllerType == .isGroupChooser || groupAndTeacherControllerType == .isGroupViewController)) ||
            (teachers.count == 0 && (groupAndTeacherControllerType == .isTeachersChooser || groupAndTeacherControllerType == .isTeacherViewController)) {
            switch groupAndTeacherControllerType {
            case .isTeachersChooser:
                segmentControl.isHidden = true
                getAllTeachers()
            case .isGroupChooser:
                segmentControl.isHidden = true
                getAllGroups()
            case .isGroupViewController:
                showWithoutStartWriteLabel()
                segmentControl.isHidden = true
                getAllGroups()
            case .isTeacherViewController:
                showWithoutStartWriteLabel()

                if settings.sheduleType == .teachers {
                    disableSegmentControl()
                    getAllTeachers()
                } else if settings.sheduleType == .groups {
                    getTeachersOfGroup()
                    getAllTeachers()
                }
            }
        }
    }
    
    /// When need to show  `tableView` now
    private func showWithoutStartWriteLabel() {
        tableView.isHidden = true
        startWriteLabel.isHidden = true
        activityIndicator.startAndShow()
        self.view.addSubview(activityIndicator)
    }
    
    /// Disable  `segmentControl` which change fom "Мої" and "Всі"
    private func disableSegmentControl() {
        segmentControl.selectedSegmentIndex = 1
        didSegmentControlChangeState(segmentControl)
        segmentControl.isHidden = true
    }

    /// Get All vaiables from `navigationController`
    private func getVariablesFromNavigationController() {
        guard let groupNavigationController = self.navigationController as? TeachersNavigationController else { return }
        self.groupAndTeacherControllerType = groupNavigationController.groupAndTeacherControllerType
    }
    
    // MARK: - SETUP functions
    private func setupTableView() {
        tableView.register(UINib(nibName: TeacherOrGroupLoadingTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: TeacherOrGroupLoadingTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = tint
    }
    
    private func setupSwitch() {
        var titleTextAttributesNormal = [NSAttributedString.Key.foregroundColor: UIColor.blue]
        let titleTextAttributesSelected = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        if #available(iOS 13.0, *) {
            titleTextAttributesNormal = [NSAttributedString.Key.foregroundColor: UIColor.link]
        }

        segmentControl.setTitleTextAttributes(titleTextAttributesNormal, for: .normal)
        segmentControl.setTitleTextAttributes(titleTextAttributesSelected, for: .selected)
    }
    
    private func setupNavigationAndSearch() {
        /// Search bar settings
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        
        setLargeTitleDisplayMode(.never)
        switch groupAndTeacherControllerType {
        case .isTeachersChooser, .isTeacherViewController:
            search.searchBar.placeholder = "Пошук викладача"
            self.title = "Викладачі"
            startWriteLabel.text = " Почніть вводити ініціали"
        case .isGroupViewController, .isGroupChooser:
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
                    activityIndicator.startAndShow()
                    getTeachersOfGroup(isNeedToUpdate: true)
                }
                
                teachers = groupTeachers
                tableView.reloadData()
            case 1:
                self.teachers = []
                
                if allTeachers.count == 0 {
                    activityIndicator.startAndShow()
                    getAllTeachers(isNeedToUpdate: true)
                }

                teachers = allTeachers
                tableView.reloadData()
            default:
                break
        }
    }
}
