//
//  FavouriteViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 20.02.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

enum typeFavourite {
    case group
    case teacher
}

class FavouriteViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let favourites = Favourites.shared
    
    var favouritesList: [(name: String, id: Int, type: typeFavourite)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setFavouritesList()
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: ServerGetTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ServerGetTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setFavouritesList() {
        favouritesList = []
        let favouriteGroupsNames = favourites.favouriteGroupsNames
        let favouriteGroupsID = favourites.favouriteGroupsID
        
        let favouriteTeachersNames = favourites.favouriteTeachersNames
        let favouriteTeachersID = favourites.favouriteTeachersID

        
        for i in 0..<favourites.favouriteGroupsNames.count {
            favouritesList.append((name: favouriteGroupsNames[i], id: favouriteGroupsID[i], .group))
        }
        
        for i in 0..<favourites.favouriteTeachersNames.count {
            favouritesList.append((name: favouriteTeachersNames[i], id: favouriteTeachersID[i], .teacher))
        }
    }
    
    func serverGetFreshShedule(group: Group, indexPath: IndexPath) {
        guard let url = URL(string: "https://api.rozklad.org.ua/v2/groups/\(String(group.groupID))/lessons") else { return }
        print(url)
        
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

extension FavouriteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouritesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServerGetTableViewCell.identifier, for: indexPath) as? ServerGetTableViewCell else { return UITableViewCell() }
        
        cell.activityIndicator.isHidden = true

        cell.mainLabel.text = favouritesList[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favouriteChoosen = favouritesList[indexPath.row]
        let group = Group(groupID: favouriteChoosen.id, groupFullName: favouriteChoosen.name, groupPrefix: "", groupOkr: .magister, groupType: .daily, groupURL: "")
        
        serverGetFreshShedule(group: group, indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
