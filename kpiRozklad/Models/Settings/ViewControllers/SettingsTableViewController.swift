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
        
        tableView.delegate = self
        tableView.dataSource = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK:- deleteAllFromCoreData
    @IBAction func didPressUpdateShedule(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Розклад", message: "Чи бажаєте Ви оновити ваш розклад?\n Всі ваші редагування розкладу пропадуть!", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Оновити", style: .default, handler: { (_) in
            Settings.shared.isTryToRefreshShedule = true
            print("press")

            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LessonData")

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

            // Configure Fetch Request
            fetchRequest.includesPropertyValues = false

            do {
                let managedContext = appDelegate.persistentContainer.viewContext

                let items = try managedContext.fetch(fetchRequest) as! [NSManagedObject]

                for item in items {
                    managedContext.delete(item)
                }

                /// Save Changes
                try managedContext.save()
                
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let groupVC : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as! UITabBarController

                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                guard let window = appDelegate?.window else { return }
                window.rootViewController = groupVC

            } catch {
                /// Error Handling
            }
            
        }))
        
        
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion: {
        })
    }
    
    
    
    @IBAction func didPressChangeGroup(_ sender: UIButton) {
        let alert = UIAlertController(title: "Група", message: "Чи бажаєте Ви змініти вашу групу?\n Всі ваші редагування розкладу пропадуть!", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Змініти", style: .default, handler: { (_) in
            Settings.shared.groupName = ""
            Settings.shared.isTryToRefreshShedule = true
            
//            let secondViewController: SheduleViewController = SheduleViewController()
//
////            self.tabBarController?.present(secondViewController, animated: true, completion: nil)
//            self.tabBarController?.selectedViewController = secondViewController
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let groupVC : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as! UITabBarController

            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            guard let window = appDelegate?.window else { return }
            window.rootViewController = groupVC
        }))
        
        
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion: {
        })
        
        
    }
    
    
    
}
