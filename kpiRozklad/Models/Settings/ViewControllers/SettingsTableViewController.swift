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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    
    @IBAction func didPressUpdateShedule(_ sender: UIButton) {
        print("press")
        // MARK:- deleteAllFromCoreData

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

        } catch {
            /// Error Handling
        }
        
    }
    
    
    
}
