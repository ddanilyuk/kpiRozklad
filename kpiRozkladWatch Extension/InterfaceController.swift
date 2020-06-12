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
    
    @IBOutlet weak var startGroup: WKInterfaceGroup!
    
    @IBOutlet weak var mainGroup: WKInterfaceGroup!
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
    
    var isGreetingOnScreen: Bool = false

    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        hideGreeting()
        setupDate()
        
        
        
        if #available(watchOSApplicationExtension 5.1, *) {
            tableView.curvesAtBottom = true
        }
        
        self.lessons = lessonsGlobal
        self.setToday()

        if lessons.count == 0 {
            self.setTitle("")
            showGreeting()
        }
        
        notificationObserver = notificationCenter.addObserver(forName: NSNotification.Name("activityNotification"), object: nil, queue: nil, using: { (notification) in
            self.hideGreeting()
            self.lessons = lessonsGlobal
            self.setToday()
        })
    }
    
    private func showGreeting() {
        isGreetingOnScreen = true
        startGroup.setHidden(false)
        mainGroup.setHidden(true)
    }
    
    private func hideGreeting() {
        isGreetingOnScreen = false
        startGroup.setHidden(true)
        mainGroup.setHidden(false)
    }
    
    private func setupDate() {
        let result = getTimeAndDayNumAndWeekOfYear()
        timeIsNowString = result.timeIsNowString
        dayNumberFromCurrentDate = result.dayNumberFromCurrentDate
        weekOfYear = result.weekOfYear
    }
    
    @IBAction func setFirstWeek() {
        setupTableView(week: "1")
        if !isGreetingOnScreen {
            self.setTitle("1 тиждень")
        }
    }
    
    @IBAction func setSecondWeek() {
        setupTableView(week: "2")
        if !isGreetingOnScreen {
            self.setTitle("2 тиждень")
        }
    }
    
    @IBAction func setToday() {
        if !isGreetingOnScreen {
            self.setTitle("Сьогодні")
        }
//        self.label.setText(nil)
        let lessonsForToday = lessons.filter { return $0.lessonWeek == String(currentWeekFromTodayDate) && $0.dayNumber == String(dayNumberFromCurrentDate) }
        
        var rowTypes: [String] = Array.init(repeating: "TableRow", count: lessonsForToday.count)
        rowTypes.insert("TitleRow", at: 0)
        
        tableView.setRowTypes(rowTypes)
        
        for index in 0..<rowTypes.count {
            if index == 0 {
                if let titleRow = tableView.rowController(at: index) as? TitleRow {
                    let title = "\(DayName.getDayNameFromNumber(dayNumberFromCurrentDate).map { $0.rawValue } ?? ""), \(currentWeekFromTodayDate) тиж."
                    titleRow.titleLabel.setText(title)
                }
                
            } else {
                if let tableRow = tableView.rowController(at: index) as? TableRow {
                    let lesson = lessonsForToday[index - 1]
                    tableRow.lesson = lesson
                    
                    if currentLessonId == lesson.lessonID {
                        setupCurrentOrNextLessonRow(row: tableRow, cellType: .currentCell)
                    } else if nextLessonId == lesson.lessonID {
                        setupCurrentOrNextLessonRow(row: tableRow, cellType: .nextCell)
                    }
                }
            }
        }
        
        
    }
    
    private func setupTableView(week: String) {
//        self.label.setText(name.uppercased())
//        tableView.remo
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
                    setupCurrentOrNextLessonRow(row: tableRow, cellType: .currentCell)
                } else if nextLessonId == lesson.lessonID {
                    setupCurrentOrNextLessonRow(row: tableRow, cellType: .nextCell)
                }
                lessonCounter += 1
            }
        }
        
    }
    
    public func setupCurrentOrNextLessonRow(row: TableRow, cellType: SheduleCellType) {
        
        if cellType == .currentCell {
            row.rowGroup.setBackgroundColor(cellCurrentColour ?? .black)
        } else if cellType == .nextCell {
            row.rowGroup.setBackgroundColor(cellNextColour ?? .black)
        }
        
        let textColour: UIColor = cellNextColour?.isWhiteText ?? true ? .white : .black

        row.lessonNameLabel.setTextColor(textColour)
        row.lessonRoomLabel.setTextColor(textColour)
        row.timeStartLabel.setTextColor(textColour)
        row.timeEndLabel.setTextColor(textColour)
    }
    
    override func willActivate() {
        super.willActivate()
//        tableView.
    }

}
