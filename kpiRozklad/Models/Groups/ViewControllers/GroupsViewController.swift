//
//  GroupsViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 20.02.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

class GroupsViewController: UIViewController {

    /// groupReuseID
    let groupReuseID = "groupReuseID"
    
    /// is searching groups
    var isSearching = false
    
    /// **Main** variable, show when `isSearching == false`
    var groups = [Group]()
    
    /// Variable, show when `isSearching == true`
    var groupsInSearch = [Group]()

    /// Search Controller
    let search = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var startWritingLabel: UILabel!
    
    @IBOutlet weak var startWritingLabelHeight: NSLayoutConstraint!
    
    var isMainGroupChooser: Bool = false
    
    let settings = Settings.shared
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        server()
        
        setupSearchAndNavigation()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: ServerGetTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ServerGetTableViewCell.identifier)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        startWritingLabel.isHidden = false
        tableView.isHidden = true
    }
    
    
    private func setupSearchAndNavigation() {
        /// Search bar settings
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Пошук групи"
        self.navigationItem.searchController = search
        self.navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    
    // MARK: - server
    /// Functon which getting data from server
    func server() {
        let decoder = JSONDecoder()

        for i in 0..<25 {
            /// Making offset because server cant send more than 100 groups for 1 request (and we making 25)
            let offset = i * 100
            
            let stringURL = "https://api.rozklad.org.ua/v2/groups/?filter=%7B'limit':100,'offset':\(String(offset))%7D"
            
            guard let url = URL(string: stringURL) else { return }
            
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }

                do {
                    guard let serverFULLDATA = try? decoder.decode(WelcomeGroup.self, from: data) else { return }
                    
                    self.groups += serverFULLDATA.data

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.groups.sort { (Group1, Group2) -> Bool in
                            return Group1.groupID < Group2.groupID
                        }
                    }
                    
                }
            }
            task.resume()
        }
    }
    
}


// MARK: - Extencions For Table View
extension GroupsViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return groupsInSearch.count
        } else {
            return groups.count
        }
    }
    
    // MARK: - cellForRowAt indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServerGetTableViewCell.identifier, for: indexPath) as? ServerGetTableViewCell else { return UITableViewCell() }
        
        cell.activityIndicator.isHidden = true

        cell.mainLabel.text = isSearching ? groupsInSearch[indexPath.row].groupFullName : groups[indexPath.row].groupFullName

        return cell
    }
    
    // MARK: - didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let window = appDelegate?.window else { return }
        
        guard let groupNavigationController = self.navigationController as? GroupsChooserNavigationController else {
            return
        }
        
        let group = isSearching ? groupsInSearch[indexPath.row] : groups[indexPath.row]

        
        
        if groupNavigationController.isMainChooser {
            settings.groupName = group.groupFullName
            settings.groupID = group.groupID
            settings.isTryToRefreshShedule = true

            guard let mainTabBar : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as? UITabBarController else { return }

            self.dismiss(animated: true, completion: {
                window.rootViewController = mainTabBar
            })
            
        } else {
            serverGetFreshShedule(group: group, indexPath: indexPath)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func serverGetFreshShedule(group: Group, indexPath: IndexPath) {
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


// MARK: - Extencions For Search
extension GroupsViewController: UISearchResultsUpdating {

    // MARK: - updateSearchResults
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text else { return }
        
        let lowerCaseSearchText = searchText.lowercased()
        
        if searchText == "" {
            isSearching = false
            groupsInSearch = []
            
            startWritingLabel.isHidden = false
        

            tableView.isHidden = true
            
            tableView.reloadData()
        } else {
            
            startWritingLabel.isHidden = true
            
            
            tableView.isHidden = false
            
            isSearching = true
            groupsInSearch = []
            
            for group in groups {
                if group.groupFullName.lowercased().contains(lowerCaseSearchText){
                    groupsInSearch.append(group)
                }
            }
            
            tableView.reloadData()
        }
    }
}

