//
//  InterfaceController.swift
//  kpiRozkladWatch Extension
//
//  Created by Денис Данилюк on 07.06.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import WatchKit
import Foundation
import CoreData


class MainInterfaceController: WKInterfaceController {
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    var lessons: [Lesson] = []
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSCustomPersistentContainer(name: "kpiRozklad")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let fullLessons = fetchingCoreData(managedContext: persistentContainer.viewContext)
        lessons = fullLessons
        
        tableView.setNumberOfRows(lessons.count, withRowType: "TableRow")
        
        for index in 0..<lessons.count {
            guard let row = tableView.rowController(at: index) as? TableRow else {
                return
            }
            row.lesson = lessons[index]
        }
        
        
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
