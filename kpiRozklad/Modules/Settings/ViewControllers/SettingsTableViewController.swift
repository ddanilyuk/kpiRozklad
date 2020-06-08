//
//  SettingsTableViewController.swift
//  kpiRozklad
//
//  Created by Denis on 26.10.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit
import CoreData
import PromiseKit


class SettingsTableViewController: UITableViewController {
    
    /// Settings singleton
    let settings = Settings.shared
    
    /// Main window
    var window: UIWindow?

    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        setupTableView()
        getServerTimeUpdate()
    }
    
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLargeTitleDisplayMode(.always)
    }
    
    
    // MARK: - SETUP functions

    private func setupTableView() {
        tableView.register(UINib(nibName: ServerUpdateTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: ServerUpdateTableViewCell.identifier)
        tableView.register(UINib(nibName: SettingsTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: SettingsTableViewCell.identifier)
        tableView.register(UINib(nibName: TeacherOrGroupLoadingTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: TeacherOrGroupLoadingTableViewCell.identifier)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = tint
    }

    
    // MARK: - Table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            return 0.0001
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
            } else if indexPath.row == 2 {
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
                didPressChangeShedule()
            } else if indexPath.row == 2 {
                didPressEditColours()
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                getLessonsFromServer()
            } else if indexPath.row == 1 {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Functions which calls
    
    /**
     Function which update shedule
     */
    func didPressUpdateShedule() {
        let alert = UIAlertController(title: nil, message: "Чи бажаєте ви оновити розклад?\n Всі ваші редагування розкладу пропадуть!", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Оновити", style: .destructive, handler: { (_) in
            
            
            self.settings.isTryToRefreshShedule = true
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            deleteAllFromCoreData(managedContext: managedContext)
            
            let indexPath = IndexPath(row: 0, section: 1)
            let formatter = DateFormatter()
            
            formatter.dateFormat = "dd.MM.yyyy"

            let time = formatter.string(from: Date())
            self.settings.sheduleUpdateTime = time
            
            if let cell = self.tableView.cellForRow(at: indexPath) as? ServerUpdateTableViewCell {
                cell.deviceSaveLabel.text = time
            }

            guard let window = appDelegate.window else { return }
            


            guard let mainTabBar: UITabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "Main") as? UITabBarController else { return }

            window.rootViewController = mainTabBar
        }))
        
        alert.addAction(UIAlertAction(title: "Скасувати", style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion: {
        })
    }
    
    
    /**
     Function which change type of shedule
     */
    func didPressChangeShedule() {
        let alert = UIAlertController(title: nil, message: "Чи бажаєте ви змінити тип розкладу \n Всі ваші редагування розкладу пропадуть!", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Змінити", style: .destructive, handler: { (_) in
            self.settings.groupName = ""
            self.settings.teacherName = ""
            self.settings.groupID = 0
            self.settings.teacherID = 0
            
            self.settings.isTryToRefreshShedule = true
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            deleteAllFromCoreData(managedContext: managedContext)
            
            let indexPath = IndexPath(row: 1, section: 1)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"

            let time = formatter.string(from: Date())
            self.settings.sheduleUpdateTime = time
            
            if let cell = self.tableView.cellForRow(at: indexPath) as? ServerUpdateTableViewCell {
                cell.deviceSaveLabel.text = time
            }
            
            guard let greetingVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: FirstViewController.identifier) as? FirstViewController else { return }
            greetingVC.modalTransitionStyle = .crossDissolve

            
            guard let window = self.window else { return }
            window.rootViewController = greetingVC
            window.makeKeyAndVisible()
            
            UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: {}, completion:
                { completed in })
        }))
        
        alert.addAction(UIAlertAction(title: "Скасувати", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /**
     Function which show `ColourPickerViewController`
     */
    func didPressEditColours() {
        guard let colourVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ColourPickerViewController") as? ColourPickerViewController else { return }
        let colorPickerView = ColorPickerView()
        for i in 0..<colorPickerView.colors.count {
            let colour = colorPickerView.colors[i]
            if colour == Settings.shared.cellCurrentColour {
                colourVC.defaultColour = colour
            }
        }
        self.navigationController?.pushViewController(colourVC, animated: true)
    }
    
    
    /**
     Function which get time when server was updated
     */
    func getServerTimeUpdate() {
        guard let url = URL(string: "https://rozklad.org.ua/?noredirect") else { return }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        
            do {
                let myHTMLString = try String(contentsOf: url)
                
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

    
    /**
     Function which take lesson fom server and swow it in `SheduleViewController`
     */
    private func getLessonsFromServer() {
        guard let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? SettingsTableViewCell else { return }
        
        cell.startLoadingCellIndicator()
        
        let serverLessons = global.sheduleType == .groups ? API.getStudentLessons(forGroupWithId: settings.groupID) : API.getTeacherLessons(forTeacherWithId: settings.teacherID)

        serverLessons.done({ [weak self] (lessons) in
            guard let this = self else { return }
            
            guard let sheduleVC: SheduleViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: SheduleViewController.identifier) as? SheduleViewController else { return }
            
            cell.stopLoadingCellIndicator()
            
            sheduleVC.isFromSettingsGetFreshShedule = true
            sheduleVC.currentWeek = 1
            sheduleVC.lessonsFromSegue = lessons
            sheduleVC.navigationItem.title = Settings.shared.groupName.uppercased()

            this.navigationController?.pushViewController(sheduleVC, animated: true)
            
        }).catch({ [weak self] (error) in
            guard let this = self else { return }
            cell.stopLoadingCellIndicator()

            let alert = UIAlertController(title: "Помилка", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Оновити", style: .default, handler: { (_) in
                this.getLessonsFromServer()
                cell.startLoadingCellIndicator()
            }))

            this.present(alert, animated: true, completion: { cell.stopLoadingCellIndicator() })
        })
    }
}
