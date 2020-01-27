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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        server()
    }
    

    private func setupTableView() {
        tableView.register(UINib(nibName: ServerUpdateTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ServerUpdateTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = tint
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Загальні"
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 2
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 50
        } else if indexPath.section == 1 {
            return 100
        } else {
            return 50
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return screenHeight / 3.2
        } else {
            return 5
        }
    }

    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        
//        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
//        print(view.layer.bounds.size.height)
//        print(screenHeight - 150)
//        label.center = CGPoint(x: 160, y: screenHeight - 150)
//        label.textAlignment = .center
//        label.text = "I'm a test label"
//        view.addSubview(label)
        
        return view
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "settings")
        
        var colour = UIColor.white
        
        if #available(iOS 13, *) {
            colour = .secondarySystemGroupedBackground
        } else {
            /// Return a fallback color for iOS 12 and lower.
            colour = UIColor.lightGray
        }
        

        if indexPath.section == 0 {
            cell.layer.cornerRadius = 0
            cell.separatorInset = .zero
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = colour

            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Оновити розклад"
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Вибрати групу"
                cell.detailTextLabel?.text = Settings.shared.groupName.uppercased()
            }
            return cell

        } else if indexPath.section == 1 {

            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ServerUpdateTableViewCell.identifier, for: indexPath) as? ServerUpdateTableViewCell else { return UITableViewCell() }
                cell.layer.cornerRadius = 30
//                cell.separatorInset = .zero
//                cell.accessoryType = .none
//
                cell.backgroundColor = colour
                cell.tintColor = colour

                cell.deviceSaveLabel.text = Settings.shared.sheduleUpdateTime
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
        }
        if indexPath.section == 1 {
             tableView.deselectRow(at: indexPath, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // MARK:- deleteAllFromCoreData
    func didPressUpdateShedule() {
        
        let alert = UIAlertController(title: nil, message: "Чи бажаєте Ви оновити ваш розклад?\n Всі ваші редагування розкладу пропадуть!", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Оновити", style: .destructive, handler: { (_) in
            
            Settings.shared.isTryToRefreshShedule = true
            deleteAllFromCoreData()
            
            let indexPath = IndexPath(row: 0, section: 1)
            let date = Date()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"

            let time = formatter.string(from: date)
            Settings.shared.sheduleUpdateTime = time
            
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
            Settings.shared.groupName = ""
            Settings.shared.isTryToRefreshShedule = true
            deleteAllFromCoreData()
            
            let indexPath = IndexPath(row: 0, section: 1)
            let date = Date()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"

            let time = formatter.string(from: date)
            Settings.shared.sheduleUpdateTime = time
            
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
    
    func server() {
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
                    
//                    print("Останнє оновлення сервера:\(String(some[1]))")  // "ab\n"
                    let indexPath = IndexPath(row: 0, section: 1)
                    DispatchQueue.main.async {
//                        self.tableView.cellForRow(at: indexPath)?.textLabel?.text = "Останнє оновлення сервера:\(String(some[1]))"
//                        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: ServerUpdateTableViewCell.identifier, for: indexPath) as? ServerUpdateTableViewCell else { return UITableViewCell() }
//                        cell.accessoryType = .none
//                        cell.layer.cornerRadius = 30

//                        cell.serverUpdateLabel.text = String(some[1])
//                        cell.deviceSaveLabel.text = "00.00.2000"
                        
                        if let cell = self.tableView.cellForRow(at: indexPath) as? ServerUpdateTableViewCell {
                            cell.serverUpdateLabel.text = String(some[1])
//                            cell.deviceSaveLabel.text = "00.00.0000"
                        }
                        
//                        self.tableView.reloadData()
                    }
                }
                
            } catch let error {
                print("Error: \(error)")
            }
            
        }
        task.resume()
    }

}
