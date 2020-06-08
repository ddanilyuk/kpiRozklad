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
    
    /**
     Сurrent week which is obtained from the date on the device
     - Remark:
        Set  up in `setupDate()`
     */
    var currentWeekFromTodayDate = 1
    
    /// Week of year from date on the device
    var weekOfYear = 0
    
    /// Day number from 1 to 7
    var dayNumberFromCurrentDate = 0
    
    /// Time is Now from device
    var timeIsNowString = String()
    
    /**
     Lesson ID of **current** Lesson
     - Remark:
        Updated in `makeLessonShedule()` but makes in `getCurrentAndNextLesson(lessons: [Lesson])`
     */
    var currentLessonId = String()
    
    /**
     Lesson ID of **next** Lesson
     - Remark:
        Updated in `makeLessonShedule()` but makes in `getCurrentAndNextLesson(lessons: [Lesson])`
     */
    var nextLessonId = String()

    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        setupDate()
        
        var currentLessonsWeek = "1"
        
        if weekOfYear % 2 != 0 {
            currentLessonsWeek = "2"
        }
        
        self.lessons = lessonsGlobal
        self.setupTableView(week: currentLessonsWeek)
        self.setTitle("\(currentLessonsWeek) тиждень")

        notificationObserver = notificationCenter.addObserver(forName: NSNotification.Name("activityNotification"), object: nil, queue: nil, using: { (notification) in
            self.label.setText(name.uppercased())

            self.lessons = lessonsGlobal
            
            self.setTitle("\(currentLessonsWeek) тиждень")
            self.setupTableView(week: currentLessonsWeek)
        })
    }
    
    private func setupDate() {
        let result = getTimeAndDayNumAndWeekOfYear()
        timeIsNowString = result.timeIsNowString
        dayNumberFromCurrentDate = result.dayNumberFromCurrentDate
        weekOfYear = result.weekOfYear
    }
    
    @IBAction func setFirstWeek() {
        setupTableView(week: "1")
        self.setTitle("1 тиждень")

    }
    @IBAction func setSecondWeek() {
        setupTableView(week: "2")
        self.setTitle("2 тиждень")
    }
    
    @IBAction func setToday() {
        self.setTitle("Сьогодні")
        let lessonsForToday = lessons.filter { return $0.lessonWeek == String(currentWeekFromTodayDate) && $0.dayNumber == String(dayNumberFromCurrentDate) }
        
        var rowTypes: [String] = Array.init(repeating: "TableRow", count: lessonsForToday.count)
        rowTypes.insert("TitleRow", at: 0)
        
        tableView.setRowTypes(rowTypes)
        
        for index in 0..<rowTypes.count {
            if index == 0 {
                if let titleRow = tableView.rowController(at: index) as? TitleRow {
                    titleRow.titleLabel.setText(DayName.getDayNameFromNumber(dayNumberFromCurrentDate).map { $0.rawValue })
                }
                
            } else {
                if let tableRow = tableView.rowController(at: index) as? TableRow {
                        let lesson = lessonsForToday[index - 1]
                        tableRow.lesson = lesson
                        
                        if currentLessonId == lesson.lessonID {
                            tableRow.rowGroup.setBackgroundColor(cellCurrentColour ?? .red)
                            
                            let textColour: UIColor = cellCurrentColour?.isWhiteText ?? true ? .white : .black
                            tableRow.lessonNameLabel.setTextColor(textColour)
                            tableRow.lessonRoomLabel.setTextColor(textColour)

                            
                        } else if nextLessonId == lesson.lessonID {
                            tableRow.rowGroup.setBackgroundColor(cellNextColour ?? .green)
                            
                            let textColour: UIColor = cellNextColour?.isWhiteText ?? true ? .white : .black
                            tableRow.lessonNameLabel.setTextColor(textColour)
                            tableRow.lessonRoomLabel.setTextColor(textColour)
                        }
                }
            }
        }
        
        
    }
    
    private func setupTableView(week: String) {
        
        setupDate()
        (nextLessonId, currentLessonId) = getCurrentAndNextLesson(lessons: lessons, timeIsNowString: timeIsNowString, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
        
        
        let lessonsWeek = lessons.filter { lesson -> Bool in
            return lesson.lessonWeek == week
        }
        
        var lessonMounday: [Lesson] = []
        var lessonTuesday: [Lesson] = []
        var lessonWednesday: [Lesson] = []
        var lessonThursday: [Lesson] = []
        var lessonFriday: [Lesson] = []
        var lessonSaturday: [Lesson] = []
        
        for datu in lessonsWeek {
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
                let lesson = lessonsDictionary[dayCounter - 1].value[lessonCounter]
                tableRow.lesson = lesson
                
                if currentLessonId == lesson.lessonID {
                    tableRow.rowGroup.setBackgroundColor(cellCurrentColour ?? .red)
                    
                    let textColour: UIColor = cellCurrentColour?.isWhiteText ?? true ? .white : .black
                    tableRow.lessonNameLabel.setTextColor(textColour)
                    tableRow.lessonRoomLabel.setTextColor(textColour)

                    
                } else if nextLessonId == lesson.lessonID {
                    tableRow.rowGroup.setBackgroundColor(cellNextColour ?? .green)
                    
                    let textColour: UIColor = cellNextColour?.isWhiteText ?? true ? .white : .black
                    tableRow.lessonNameLabel.setTextColor(textColour)
                    tableRow.lessonRoomLabel.setTextColor(textColour)
                }
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
