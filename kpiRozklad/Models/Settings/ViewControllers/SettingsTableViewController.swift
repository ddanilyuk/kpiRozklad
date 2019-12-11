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
    }
    

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = tint
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Загальні"
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 200
    }

    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "settings")
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Оновити розклад"
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Вибрати групу"
                cell.detailTextLabel?.text = Settings.shared.groupName.uppercased()
            }
        }
        cell.accessoryType = .disclosureIndicator
        
        var colour = UIColor.white
        
        if #available(iOS 13, *) {
            colour = .secondarySystemGroupedBackground
        } else {
            /// Return a fallback color for iOS 12 and lower.
            colour = UIColor.lightGray
        }
        
        cell.backgroundColor = colour

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
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // MARK:- deleteAllFromCoreData
    func didPressUpdateShedule() {
        
        let alert = UIAlertController(title: nil, message: "Чи бажаєте Ви оновити ваш розклад?\n Всі ваші редагування розкладу пропадуть!", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Оновити", style: .default, handler: { (_) in
            
//            Settings.shared.isTryToRefreshShedule = true
            deleteAllFromCoreData()
            
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
        alert.addAction(UIAlertAction(title: "Змінити", style: .default, handler: { (_) in
            Settings.shared.groupName = ""
            Settings.shared.isTryToRefreshShedule = true
            deleteAllFromCoreData()
            
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

}
