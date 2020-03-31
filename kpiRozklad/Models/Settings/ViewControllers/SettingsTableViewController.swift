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
    
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        setLargeTitleDisplayMode(.always)

    }
    

    private func setupTableView() {
        tableView.register(UINib(nibName: ServerUpdateTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ServerUpdateTableViewCell.identifier)
        
        tableView.register(UINib(nibName: SettingsTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: SettingsTableViewCell.identifier)
        
        
        tableView.register(UINib(nibName: TeacherOrGroupLoadingTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: TeacherOrGroupLoadingTableViewCell.identifier)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = tint
        tableView.tintColor = .blue

//        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.001))
//        tableView.tableFooterView = UIView()
        

    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
//    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        if section == 1 {
//            return "footer"
//        }
//        return ""
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {

            return 3
        } else if section == 1 {

            return 2
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 45
        } else if indexPath.section == 1 {
            if indexPath.row == 1 {
                return 100
            } else {
                return 45
            }
        } else {
            return 45
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 50
        } else {
            return 25
        }
    }
//
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        let view = UIView()

        view.backgroundColor = tint
        return view
    }
//
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerView = UIView()
//        let dummyView = UIView() //just a dummy view to return
//        let separatorView = UIView(frame: CGRect(x: tableView.separatorInset.left, y: footerView.frame.height, width: tableView.frame.width - tableView.separatorInset.right - tableView.separatorInset.left, height: 0.5))
//        separatorView.backgroundColor = UIColor.white
//        footerView.addSubview(separatorView)
//
//        if section == 0 {
//            return footerView
//        }
//        return dummyView
//    }
//
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = tint
        return view
    }
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        cell.layoutMargins = .zero
//        cell.separatorInset = .zero
//        if indexPath.section == 1 {
//            if indexPath.row == 1 {
//                cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
//
//            }
//        }
//    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "settings")
    
        cell.backgroundColor = seettingsTableViewBackgroundColour
        
        if indexPath.section == 0 {
            cell.separatorInset = .zero
            cell.accessoryType = .disclosureIndicator

            if indexPath.row == 0 {
                cell.textLabel?.text = "Оновити розклад"
                cell.imageView?.image = UIImage(named: "icons8-refresh-80-orange")
            } else if indexPath.row == 1 {
                let name = global.sheduleType == .groups ? "групу" : "викладача"
                cell.textLabel?.text = "Змінити \(name)"
                cell.imageView?.image = UIImage(named: "icons8-refresh-80-red")
                cell.detailTextLabel?.text = settings.groupName.uppercased()
            }
            else if indexPath.row == 2 {

                cell.textLabel?.text = "Колір поточної та наступної пари"
                cell.imageView?.image = UIImage(named: "icons8-paint-brush-80")

            }
            return cell

        } else if indexPath.section == 1 {

            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as? SettingsTableViewCell else { return UITableViewCell() }
                
                cell.backgroundColor = seettingsTableViewBackgroundColour
                cell.accessoryType = .disclosureIndicator
                cell.imageDetailView.image = UIImage(named: "icons8-index-80")
                cell.mainLabel.text = "Розклад без змін"
                cell.activityIndicator.isHidden = true
                cell.separator(shouldBeHidden: true)
                
                return cell
                
            } else if indexPath.row == 1 {

                guard let cell = tableView.dequeueReusableCell(withIdentifier: ServerUpdateTableViewCell.identifier, for: indexPath) as? ServerUpdateTableViewCell else { return UITableViewCell() }

                cell.backgroundColor = tint
                cell.selectionStyle = .none
                cell.separator(shouldBeHidden: true)
                cell.deviceSaveLabel.text = settings.sheduleUpdateTime

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
                didPressChangeSheduleType()
            } else if indexPath.row == 2 {
                didPressEditColours()
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                serverGetFreshShedule(requestType: global.sheduleType)
            } else if indexPath.row == 1 {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    // MARK:- deleteAllFromCoreData
    func didPressUpdateShedule() {
        
        let alert = UIAlertController(title: nil, message: "Чи бажаєте ви оновити розклад?\n Всі ваші редагування розкладу пропадуть!", preferredStyle: .actionSheet)
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
        let alert = UIAlertController(title: nil, message: "Чи бажаєте ви змінити вашу групу?\n Всі ваші редагування розкладу пропадуть!", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Змінити", style: .destructive, handler: { (_) in
            self.settings.groupName = ""
            self.settings.teacherName = ""

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
    
    func didPressEditColours() {
        guard let colourVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ColourPickerViewController") as? ColourPickerViewController else { return }
//        colourVC.navigationController?.navigationBar.prefersLargeTitles = false
//        colourVC.navigationItem.largeTitleDisplayMode = .never
//        colourVC.navigationController?.navigationItem.largeTitleDisplayMode = .never
        
//        var index = 0
        let colorPickerView = ColorPickerView()
        for i in 0..<colorPickerView.colors.count {
            let colour = colorPickerView.colors[i]
            if colour == Settings.shared.cellCurrentColour {
                colourVC.defaultColour = colour
            }
        }
        
        self.navigationController?.pushViewController(colourVC, animated: true)
    }
    
    func didPressChangeSheduleType() {
        let alert = UIAlertController(title: nil, message: "Чи бажаєте ви змінити тип розкладу \n Всі ваші редагування розкладу пропадуть!", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Змінити", style: .destructive, handler: { (_) in
            self.settings.groupName = ""
            self.settings.teacherName = ""
            
            self.settings.groupID = 0
            self.settings.teacherID = 0
            
            self.settings.isTryToRefreshShedule = true
            deleteAllFromCoreData()
            
            let indexPath = IndexPath(row: 1, section: 1)
            let date = Date()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"

            let time = formatter.string(from: date)
            self.settings.sheduleUpdateTime = time
            
            if let cell = self.tableView.cellForRow(at: indexPath) as? ServerUpdateTableViewCell {
                cell.deviceSaveLabel.text = time
            }
            
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//            guard let greetingVC = mainStoryboard.instantiateViewController(withIdentifier: "GreetingViewController") as? GreetingViewController else { return }

            guard let greetingVC = mainStoryboard.instantiateViewController(withIdentifier: "FirstViewController") as? FirstViewController else { return }
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            guard let window = appDelegate?.window else { return }
            window.rootViewController = greetingVC
            
            
            window.makeKeyAndVisible()
            
            let options: UIView.AnimationOptions = .transitionCrossDissolve
            greetingVC.modalTransitionStyle = .crossDissolve

            let duration: TimeInterval = 0.4

        
            UIView.transition(with: window, duration: duration, options: options, animations: {}, completion:
                { completed in
            })
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Скасувати", style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion: {
        })
    }
    
    
    func serverTimeUpdate() {
        guard let url = URL(string: "https://rozklad.org.ua/?noredirect") else { return }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        
            do {
                let myHTMLString = try String(contentsOf: url)
//                print("HTML : \(myHTMLString)")
                
                if let index = myHTMLString.index(of: "Останнє оновлення: "), let index2 = myHTMLString.index(of: "<!--Всього") {
                    let substring = myHTMLString[index..<index2]   // ab
                    let string = String(substring)

                    let some = string.split(separator: ":")
                    
                    let indexPath = IndexPath(row: 1, section: 1)
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
    
    
    func serverGetFreshShedule(requestType: SheduleType) {
        var requestString = ""
        if requestType == .groups {
            requestString = "groups/\(settings.groupID)"
        } else if requestType == .teachers{
            requestString = "teachers/\(settings.teacherID)"
        }
        guard let url = URL(string: "https://api.rozklad.org.ua/v2/\(requestString)/lessons") else { return }
        let indexPath = IndexPath(row: 0, section: 1)
        
        DispatchQueue.main.async {
            if let cell = self.tableView.cellForRow(at: indexPath) as? SettingsTableViewCell {
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
                    
                    if let cell = self.tableView.cellForRow(at: indexPath) as? SettingsTableViewCell {
                        cell.activityIndicator.isHidden = true
                        cell.activityIndicator.stopAnimating()
                    }

                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    guard let sheduleVC : SheduleViewController = mainStoryboard.instantiateViewController(withIdentifier: SheduleViewController.identifier) as? SheduleViewController else { return }
                    
                    sheduleVC.isFromSettingsGetFreshShedule = true
                    sheduleVC.currentWeek = 1
                    sheduleVC.lessonsFromSegue = serverFULLDATA.data
                    sheduleVC.navigationItem.title = Settings.shared.groupName.uppercased()

                    
                    sheduleVC.navigationController?.navigationBar.prefersLargeTitles = true
                    sheduleVC.navigationItem.largeTitleDisplayMode = .never
                    sheduleVC.navigationController?.navigationItem.largeTitleDisplayMode = .never

                    
                    self.navigationController?.pushViewController(sheduleVC, animated: true)
                }
            }
        }
        task.resume()
    }
}



