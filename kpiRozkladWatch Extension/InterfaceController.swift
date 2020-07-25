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


enum SelectedControllerType {
    case firstWeek
    case secondWeek
    case today
}


class InterfaceController: WKInterfaceController {
    
    // MARK: - variables
    
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
    var currentWeekFromTodayDate: WeekType = .first
    
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
    var currentLessonId: Int = 0
    
    /**
     Lesson ID of **next** Lesson
     - Remark:
        Updated in `makeLessonShedule()` but makes in `getCurrentAndNextLesson(lessons: [Lesson])`
     */
    var nextLessonId: Int = 0
        
    var selectedLessons: [Lesson?] = []
    
    let storeUserDefaults = StoreUserDefaults.shared

    // MARK: - --------
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setupDate()

        lessons = StoreUserDefaults.shared.lessons

        if lessons.count == 0 {
            self.setTitle("")
            self.pushController(withName: "GreetingInterfaceController", context: nil)
        } else {
            setToday()
        }
        
        notificationObserver = notificationCenter.addObserver(forName: NSNotification.Name("lessonsData"), object: nil, queue: nil, using: { (notification) in
            DispatchQueue.main.async { [weak self] in
                if !(self?.storeUserDefaults.isShowGreetings ?? true) {
                    let action = WKAlertAction(title: "Зрозуміло", style: .default) { }
                    self?.presentAlert(withTitle: nil,
                                       message: "В цьому додатку відображається розклад для 3 актуальних пар.",
                                       preferredStyle: .alert,
                                       actions: [action])
                    self?.storeUserDefaults.isShowGreetings = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
                self?.lessons = self?.storeUserDefaults.lessons ?? []
                self?.setToday()
            }
        })
    }
    
    func setToday() {
        self.setTitle(storeUserDefaults.groupOrTeacherName)
        setupTableViewForToday()
        if #available(watchOSApplicationExtension 5.1, *) {
            tableView.curvesAtBottom = true
        }
    }

    // MARK: - Table functions
    private func setupTableViewForToday() {
        setupDate()

        let (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getCurrentWeekAndDayNumber()
        (nextLessonId, currentLessonId) = getCurrentAndNextLesson(lessons: lessons, timeIsNowString: timeIsNowString, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
        let (firstNextLessonID, secondNextLessonID, thirdNextLessonID) = getNextThreeLessonsID(lessons: lessons, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
        
        
        
        var lessonsForToday: [Lesson] = []
        if let firstLesson = lessons.first(where: { return $0.id == firstNextLessonID }),
           let secondLesson = lessons.first(where: { return $0.id == secondNextLessonID }),
           let thirdLesson = lessons.first(where: { return $0.id == thirdNextLessonID }){
            lessonsForToday = [firstLesson, secondLesson, thirdLesson]
        }
        print("-----------------------")
        print("currentLessonId", currentLessonId)
        print("nextLessonId", nextLessonId)
        print("lessonsForToday[0].id", lessonsForToday[0].id)
        print("lessonsForToday[1].id", lessonsForToday[1].id)

        if lessonsForToday[0].dayNumber == dayNumberFromCurrentDate {
            let date = Date()
            let (dateStart, dateEnd) = getDateStartAndEnd(of: lessonsForToday[0])
            var timeIntervalToUpdate: Int = 0
            if dateStart > date {
                timeIntervalToUpdate = Int(dateStart.timeIntervalSinceNow)
            } else if dateStart <= date && dateEnd > date {
                timeIntervalToUpdate = Int(dateEnd.timeIntervalSinceNow)
            }
            print(timeIntervalToUpdate)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(timeIntervalToUpdate)) { [weak self] in
                self?.setupTableViewForToday()
            }
        }
        
        selectedLessons = lessonsForToday

        let rowTypes: [String] = Array.init(repeating: "TableRow", count: lessonsForToday.count)
        tableView.setRowTypes([])
        tableView.setRowTypes(rowTypes)
        
        for index in 0..<rowTypes.count {
            if let tableRow = tableView.rowController(at: index) as? TableRow {
                let lesson = lessonsForToday[index]
                tableRow.lesson = lesson
                
                if currentLessonId == lesson.id {
                    setupCurrentOrNextLessonRow(row: tableRow, cellType: .currentCell)
                } else if nextLessonId == lesson.id {
                    setupCurrentOrNextLessonRow(row: tableRow, cellType: .nextCell)
                }
            }
        }
    }

    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if selectedLessons.count > 1 {
            self.pushController(withName: "DetailedInterfaceController", context: selectedLessons[rowIndex])
        }
    }
    
    // MARK: - Helpers
    private func setupDate() {
        let result = getTimeAndDayNumAndWeekOfYear()
        timeIsNowString = result.timeIsNowString
        dayNumberFromCurrentDate = result.dayNumberFromCurrentDate
        weekOfYear = result.weekOfYear
    }
    
    public func setupCurrentOrNextLessonRow(row: TableRow, cellType: SheduleCellType) {
        
        if cellType == .currentCell {
            row.rowGroup.setBackgroundColor(storeUserDefaults.cellCurrentColour)
        } else if cellType == .nextCell {
            row.rowGroup.setBackgroundColor(storeUserDefaults.cellNextColour)
        }
        
        let textColour: UIColor = storeUserDefaults.cellNextColour.isWhiteText ? .white : .black

        row.lessonNameLabel.setTextColor(textColour)
        row.lessonRoomLabel.setTextColor(textColour)
        row.timeStartLabel.setTextColor(textColour)
        row.timeEndLabel.setTextColor(textColour)
    }
    
//    override func willActivate() {
//        setupTableViewForToday()
//    }
}
