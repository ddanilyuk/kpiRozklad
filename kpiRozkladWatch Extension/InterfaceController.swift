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
    
    var selectedLessons: [Lesson?] = []

    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        hideGreeting()
        setupDate()
        

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
//        tableView.scrollToRow(at: 0)
        isGreetingOnScreen = true
        startGroup.setHidden(false)
        mainGroup.setHidden(true)
    }
    
    private func hideGreeting() {
//        tableView.scrollToRow(at: 0)
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
        if #available(watchOSApplicationExtension 5.1, *) {
            tableView.curvesAtBottom = false
        }

        tableView.scrollToRow(at: 0)

        setupTableView(week: "1")
        if !isGreetingOnScreen {
            self.setTitle("1 тиждень")
        }
    }
    
    @IBAction func setSecondWeek() {
        if #available(watchOSApplicationExtension 5.1, *) {
            tableView.curvesAtBottom = false
        }
        
        tableView.scrollToRow(at: 0)

        setupTableView(week: "2")
        if !isGreetingOnScreen {
            self.setTitle("2 тиждень")
        }
    }
    
    @IBAction func setToday() {
        tableView.scrollToRow(at: 0)
        if #available(watchOSApplicationExtension 5.1, *) {
            tableView.curvesAtBottom = false
        }
        
        if !isGreetingOnScreen {
            self.setTitle("Сьогодні")
        }

        let lessonsForToday = lessons.filter { return $0.lessonWeek == String(currentWeekFromTodayDate) && $0.dayNumber == String(dayNumberFromCurrentDate) }
        
        selectedLessons = lessonsForToday
        
        let isEmptyLessons: Bool = lessonsForToday.count == 0 ? true : false
        
        var rowTypes: [String] = isEmptyLessons ? ["TableRow"] : Array.init(repeating: "TableRow", count: lessonsForToday.count)
        
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
                    if isEmptyLessons {
                        tableRow.lessonNameLabel.setText("Пар немає.")
                        tableRow.lessonNameLabel.setHorizontalAlignment(.center)
                        tableRow.lessonNameLabel.setVerticalAlignment(.center)

                        
                        tableRow.lessonRoomLabel.setHidden(true)
                        tableRow.timeStartLabel.setHidden(true)
                        tableRow.timeEndLabel.setHidden(true)

                    } else {
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
            if #available(watchOSApplicationExtension 5.1, *) {
                tableView.curvesAtBottom = true
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
        selectedLessons = []
        
        tableView.setRowTypes(rowTypes)
        var dayCounter: Int = 0
        var lessonCounter: Int = 0
            
        for index in 0..<rowTypes.count {
            if let titleRow = tableView.rowController(at: index) as? TitleRow {
                titleRow.titleLabel.setText(lessonsDictionary[dayCounter].key.rawValue)
                dayCounter += 1
                lessonCounter = 0
                selectedLessons.append(nil)
            } else if let tableRow = tableView.rowController(at: index) as? TableRow {
                let lesson = lessonsDictionary[dayCounter - 1].value[lessonCounter]
                tableRow.lesson = lesson
                selectedLessons.append(lesson)

                if currentLessonId == lesson.lessonID {
                    setupCurrentOrNextLessonRow(row: tableRow, cellType: .currentCell)
                } else if nextLessonId == lesson.lessonID {
                    setupCurrentOrNextLessonRow(row: tableRow, cellType: .nextCell)
                }
                lessonCounter += 1
            }
        }
        if #available(watchOSApplicationExtension 5.1, *) {
            tableView.curvesAtBottom = true
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
    
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if selectedLessons.count != 0 {
            self.pushController(withName: "DetailedInterfaceController", context: selectedLessons[rowIndex])
        }
    }
    
    
    override func willActivate() {
        super.willActivate()
        if #available(watchOSApplicationExtension 5.1, *) {
            tableView.curvesAtBottom = true
        }
    }

}
