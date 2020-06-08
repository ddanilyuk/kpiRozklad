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
    
    var daysArray: [String] = [DayName.mounday.rawValue,
                               DayName.tuesday.rawValue,
                               DayName.wednesday.rawValue,
                               DayName.thursday.rawValue,
                               DayName.friday.rawValue,
                               DayName.saturday.rawValue]

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.lessons = lessonsGlobal
        self.setupTableView()

        
        notificationObserver = notificationCenter.addObserver(forName: NSNotification.Name("activityNotification"), object: nil, queue: nil, using: { (notification) in
            self.label.setText("updated!!!!!")

            self.lessons = lessonsGlobal
            self.setupTableView()
        })
    }
    
    
    private func setupTableView() {
        
        let lessonsWeekFirst = lessons.filter { lesson -> Bool in
            return lesson.lessonWeek == "1"
        }
        
        var lessonMounday: [Lesson] = []
        var lessonTuesday: [Lesson] = []
        var lessonWednesday: [Lesson] = []
        var lessonThursday: [Lesson] = []
        var lessonFriday: [Lesson] = []
        var lessonSaturday: [Lesson] = []
        
        for datu in lessonsWeekFirst {
            switch datu.dayName {
            case .mounday:
                lessonMounday.append(datu)
            case .tuesday:
                lessonTuesday.append(datu)
            case .wednesday:
                lessonWednesday.append(datu)
            case .thursday:
                lessonThursday.append(datu)
            case .friday:
                lessonFriday.append(datu)
            case .saturday:
                lessonSaturday.append(datu)
            }
        }
        
        let lessonsDictionary = [DayName.mounday: lessonMounday,
                                 DayName.tuesday: lessonTuesday,
                                 DayName.wednesday: lessonWednesday,
                                 DayName.thursday: lessonThursday,
                                 DayName.friday: lessonFriday,
                                 DayName.saturday: lessonSaturday].sorted{$0.key < $1.key}
        var rowTypes: [String] = []
        
        for lessonsForSomeDay in lessonsDictionary {
            rowTypes.append("TitleRow")
            for _ in lessonsForSomeDay.value {
                rowTypes.append("TableRow")
            }
        }
        
        tableView.setRowTypes(rowTypes)
        var dayCounter: Int = 0
        var lessonCounter: Int = 0
            
        for index in 0..<rowTypes.count {
            if let titleRow = tableView.rowController(at: index) as? TitleRow {
                titleRow.titleLabel.setText(lessonsDictionary[dayCounter].key.rawValue)
                dayCounter += 1
                lessonCounter = 0
            } else if let tableRow = tableView.rowController(at: index) as? TableRow {
                tableRow.lesson = lessonsDictionary[dayCounter - 1].value[lessonCounter]
                lessonCounter += 1
            }
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
