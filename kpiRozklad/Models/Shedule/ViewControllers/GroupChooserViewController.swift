//
//  GroupChooserViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 11.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

class GroupChooserViewController: UIViewController {
    let groupReuseID = "groupReuseID"
    
    var groups = [Group]()
    
    
    var isSearching = false
    let search = UISearchController(searchResultsController: nil)
    var groupsInSearch = [Group]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        server()
        
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Пошук групи"
        self.navigationItem.searchController = search
        definesPresentationContext = true
        // Do any additional setup after loading the view.
    }
    
    func server() {
        for i in 0..<24 {
            let offset = i * 100
            let stringURL = "https://api.rozklad.org.ua/v2/groups/?filter=%7B'limit':100,'offset':\(String(offset))%7D"
            print(stringURL)
            let url = URL(string: stringURL)!
            
            
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()

                do {
                    guard let serverFULLDATA = try? decoder.decode(WelcomeGroup.self, from: data) else { return }
                    let datum = serverFULLDATA.data
                    self.groups += datum
//                    print("--------")
//                    print(offset)
//                    print("--------")
//                    for dat in datum {
//                        print(dat.groupID)
//                    }
                    print(self.groups.count)
                    DispatchQueue.main.async {
                        self.tableView.isHidden = false
                        self.tableView.reloadData()
                    }
                }
            }
            task.resume()
        }

    }


}


//Mark: - extencions for search
extension GroupChooserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
             return groupsInSearch.count
        } else {
            return groups.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: groupReuseID)
        
        if isSearching {
            cell.textLabel?.text = groupsInSearch[indexPath.row].groupFullName
        } else {
            cell.textLabel?.text = groups[indexPath.row].groupFullName
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        if isSearching {
            Settings.shared.groupName =  groupsInSearch[indexPath.row].groupFullName
            Settings.shared.groupID =  groupsInSearch[indexPath.row].groupID

        } else {
            Settings.shared.groupName = groups[indexPath.row].groupFullName
            Settings.shared.groupID =  groups[indexPath.row].groupID
        }
        
//        let secondViewController: SheduleViewController = SheduleViewController()
        
        //
        //
        //        print(Settings.shared.groupName)
        //        self.present(groupVC, animated: true, completion: nil)
                
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let groupVC : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as! UITabBarController
        
        Settings.shared.isTryToRefreshShedule = true

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let window = appDelegate?.window else { return }
        window.rootViewController = groupVC
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
}

//Mark: - extencions for search
extension GroupChooserViewController: UISearchResultsUpdating{

    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text else {
            return
        }
        
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

