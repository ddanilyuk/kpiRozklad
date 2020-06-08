//
//  InterfaceController.swift
//  kpiRozkladWatch Extension
//
//  Created by Денис Данилюк on 07.06.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var label: WKInterfaceLabel!
    
    @IBOutlet weak var tableView: WKInterfaceTable!
    
    lazy var notificationCenter: NotificationCenter = {
            return NotificationCenter.default
    }()
        
    var notificationObserver: NSObjectProtocol?
    
    var lessons: [Lesson] = []

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.lessons = lessonsGlobal
        self.setupTableView()

        
        notificationObserver = notificationCenter.addObserver(forName: NSNotification.Name("activityNotification"), object: nil, queue: nil, using: { (notification) in
            self.label.setText("updated!!!!!")
//            let applicationContext = WCSession.default.applicationContext
//            guard let data = applicationContext["lessons5"] as? Data else { fatalError("no data") }
//
//            let decoder = JSONDecoder.init()
//            do {
//                self.lessons = try decoder.decode([Lesson].self, from: data)
//            } catch {
//                print(error.localizedDescription)
//            }
            self.lessons = lessonsGlobal
            
            print(self.lessons.count)
            
            self.setupTableView()
        })
    }
    
    
    private func setupTableView() {
        tableView.setNumberOfRows(lessons.count, withRowType: "TableRow")
        
        for index in 0..<lessons.count {
            guard let row = tableView.rowController(at: index) as? TableRow else {
                return
            }
            row.lesson = lessons[index]
        }
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
