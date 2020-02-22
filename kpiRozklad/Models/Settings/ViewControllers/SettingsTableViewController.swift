//
//  SettingsTableViewController.swift
//  kpiRozklad
//
//  Created by Denis on 26.10.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit
import CoreData

class SettingsTableViewController: UITableViewController {

    var settings = Settings.shared
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        serverTimeUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.backgroundColor = tint
    }
    

    private func setupTableView() {
        tableView.register(UINib(nibName: ServerUpdateTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ServerUpdateTableViewCell.identifier)
        
        tableView.register(UINib(nibName: ServerGetTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ServerGetTableViewCell.identifier)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = tint
        tableView.tintColor = .blue
        
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 2
        } else if section == 1 {
            return 2
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                return 100
            } else {
                return 50
            }
        } else {
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return screenHeight / 5
        } else {
            return 5
        }
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = tint
        return view
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = tint
        return view
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "settings")
        
        var colour = UIColor.white
        
        if #available(iOS 13, *) {
            colour = .secondarySystemGroupedBackground
        } else {
            /// Return a fallback color for iOS 12 and lower.
            colour = UIColor.white
        }
        
        cell.layer.cornerRadius = 0
        cell.backgroundColor = colour


        if indexPath.section == 0 {
            cell.separatorInset = .zero
            cell.accessoryType = .disclosureIndicator

            if indexPath.row == 0 {
                cell.textLabel?.text = "Оновити розклад"
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Вибрати групу"
                cell.detailTextLabel?.text = settings.groupName.uppercased()
            }
            return cell

        } else if indexPath.section == 1 {

            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ServerUpdateTableViewCell.identifier, for: indexPath) as? ServerUpdateTableViewCell else { return UITableViewCell() }

                cell.tintColor = colour
                cell.backgroundColor = colour
                cell.deviceSaveLabel.text = settings.sheduleUpdateTime
                
                return cell
            } else if indexPath.row == 1 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ServerGetTableViewCell.identifier, for: indexPath) as? ServerGetTableViewCell else { return UITableViewCell() }
                
                cell.backgroundColor = colour
                cell.accessoryType = .disclosureIndicator
                cell.activityIndicator.isHidden = true
                
                return cell
            }
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                didPressUpdateShedule()
            } else if indexPath.row == 1 {
                didPressChangeGroup()
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                tableView.deselectRow(at: indexPath, animated: true)
            } else if indexPath.row == 1 {
                serverGetFreshShedule()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // MARK:- deleteAllFromCoreData
    func didPressUpdateShedule() {
        
        let alert = UIAlertController(title: nil, message: "Чи бажаєте Ви оновити ваш розклад?\n Всі ваші редагування розкладу пропадуть!", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Оновити", style: .destructive, handler: { (_) in
            
            self.settings.isTryToRefreshShedule = true
            deleteAllFromCoreData()
            
            let indexPath = IndexPath(row: 0, section: 1)
            let date = Date()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"

            let time = formatter.string(from: date)
            self.settings.sheduleUpdateTime = time
            
            if let cell = self.tableView.cellForRow(at: indexPath) as? ServerUpdateTableViewCell {
                cell.deviceSaveLabel.text = time
            }

            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            guard let window = appDelegate?.window else { return }

            guard let mainTabBar : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as? UITabBarController else { return }

            window.rootViewController = mainTabBar
        }))
        
        alert.addAction(UIAlertAction(title: "Скасувати", style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion: {
        })
    }
    
    
    func didPressChangeGroup() {
        let alert = UIAlertController(title: nil, message: "Чи бажаєте Ви змінити вашу групу?\n Всі ваші редагування розкладу пропадуть!", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Змінити", style: .destructive, handler: { (_) in
            self.settings.groupName = ""
            self.settings.isTryToRefreshShedule = true
            deleteAllFromCoreData()
            
            let indexPath = IndexPath(row: 0, section: 1)
            let date = Date()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"

            let time = formatter.string(from: date)
            self.settings.sheduleUpdateTime = time
            
            if let cell = self.tableView.cellForRow(at: indexPath) as? ServerUpdateTableViewCell {
                cell.deviceSaveLabel.text = time
            }
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let mainTabBar : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as? UITabBarController else { return }

            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            guard let window = appDelegate?.window else { return }
            window.rootViewController = mainTabBar
        }))
        
        alert.addAction(UIAlertAction(title: "Скасувати", style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion: {
        })
    }
    
    
    
    func serverTimeUpdate() {
        guard let url = URL(string: "https://rozklad.org.ua/?noredirect") else { return }
        
        print(url)
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        
            do {
                let myHTMLString = try String(contentsOf: url)
                print("HTML : \(myHTMLString)")
                
                if let index = myHTMLString.index(of: "Останнє оновлення: "), let index2 = myHTMLString.index(of: "<!--Всього") {
                    let substring = myHTMLString[index..<index2]   // ab
                    let string = String(substring)

                    let some = string.split(separator: ":")
                    
                    let indexPath = IndexPath(row: 0, section: 1)
                    DispatchQueue.main.async {
                        
                        if let cell = self.tableView.cellForRow(at: indexPath) as? ServerUpdateTableViewCell {
                            cell.serverUpdateLabel.text = String(some[1])
                        }
                    }
                }
                
            } catch let error {
                print("Error: \(error)")
            }
            
        }
        task.resume()
    }
    
    
    func serverGetFreshShedule() {
        guard let url = URL(string: "https://api.rozklad.org.ua/v2/groups/\(settings.groupID)/lessons") else { return }
        let indexPath = IndexPath(row: 1, section: 1)
        
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: indexPath) as? ServerGetTableViewCell {
                cell.activityIndicator.isHidden = false
                cell.activityIndicator.startAnimating()
                self.navigationController?.navigationBar.prefersLargeTitles = false
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
                    
                    sheduleVC.isFromSettingsGetFreshShedule = true
                    sheduleVC.currentWeek = 1
                    sheduleVC.lessonsFromServer = serverFULLDATA.data
                    sheduleVC.navigationItem.title = Settings.shared.groupName.uppercased()

                    
                    sheduleVC.navigationController?.navigationItem.largeTitleDisplayMode = .never
                    sheduleVC.navigationController?.navigationBar.prefersLargeTitles = false
                    sheduleVC.navigationItem.largeTitleDisplayMode = .never
                    
                    self.navigationController?.pushViewController(sheduleVC, animated: true)
                }
            }
        }
        task.resume()
    }
}
