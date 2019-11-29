//
//  GroupChooserViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 11.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

class GroupChooserViewController: UIViewController {
    
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
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        /// TableView delegate and dataSource
        tableView.dataSource = self
        tableView.delegate = self
        
        /// 
        server()
        
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
        for i in 0..<25 {
            /// Making offset because server cant send more than 100 groups for 1 request (and we making 25)
            let offset = i * 100
            
            let stringURL = "https://api.rozklad.org.ua/v2/groups/?filter=%7B'limit':100,'offset':\(String(offset))%7D"
            
            let url = URL(string: stringURL)!
            
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()

                do {
                    guard let serverFULLDATA = try? decoder.decode(WelcomeGroup.self, from: data) else { return }
                    let datum = serverFULLDATA.data
                    self.groups += datum

                    DispatchQueue.main.async {
                        self.tableView.isHidden = false
                        self.tableView.reloadData()
                        self.groups.sort { (Group1, Group2) -> Bool in
                            return Group1.groupID < Group2.groupID
                        }
                    }
                    
                }
                
                
            }
            task.resume()
        }
//        self.groups.sort { (Group1, Group2) -> Bool in
//            return Group1.groupID < Group2.groupID
//        }

    }
}


// MARK: - Extencions For Table View
extension GroupChooserViewController: UITableViewDelegate, UITableViewDataSource {
    
    
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
        let cell = UITableViewCell(style: .default, reuseIdentifier: groupReuseID)
        
        if isSearching {
            cell.textLabel?.text = groupsInSearch[indexPath.row].groupFullName
        } else {
            cell.textLabel?.text = groups[indexPath.row].groupFullName
        }
        return cell
    }
    
    
    // MARK: - didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isSearching {
            Settings.shared.groupName =  groupsInSearch[indexPath.row].groupFullName
            Settings.shared.groupID =  groupsInSearch[indexPath.row].groupID
        } else {
            Settings.shared.groupName = groups[indexPath.row].groupFullName
            Settings.shared.groupID =  groups[indexPath.row].groupID
        }
                        
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let window = appDelegate?.window else { return }
        
        
        guard let mainTabBar : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as? UITabBarController else { return }
        guard let sheduleVC: SheduleViewController = mainStoryboard.instantiateViewController(withIdentifier: SheduleViewController.identifier) as? SheduleViewController else { return }
        
        Settings.shared.isTryToRefreshShedule = true
        
        sheduleVC.server()
        
        
        self.dismiss(animated: true, completion: {
            window.rootViewController = mainTabBar
        })
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


// MARK: - Extencions For Search
extension GroupChooserViewController: UISearchResultsUpdating{

    
    // MARK: - updateSearchResults
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text else { return }
        
        let lowerCaseSearchText = searchText.lowercased()
        
        if searchText == "" {
            isSearching = false
            groupsInSearch = []
            tableView.reloadData()
        } else {
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

