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
    
    @IBOutlet weak var startGroup: WKInterfaceGroup!
    
//    @IBOutlet weak var mainGroup: WKInterfaceGroup!
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
    
    var selectedControllerType: SelectedControllerType = .today
    
    var selectedLessons: [Lesson?] = []
    
    var isMenuShown: Bool = false
    
    let storeUserDefaults = StoreUserDefaults.shared

    // MARK: - --------
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let id = self.value(forKey: "_viewControllerID") as? NSString {
            let strClassDescription = String(describing: self)
            print("1")
            print("\(strClassDescription) has the Interface Controller ID \(id)")
        }
        
        setupDate()
        
        
//        StoreUserDefaults.shared.lessons = []
        lessons = StoreUserDefaults.shared.lessons

        if lessons.count == 0 {
            self.setTitle("")
            self.pushController(withName: "GreetingInterfaceController", context: nil)
        } else {
            setToday()
        }

//        let action = WKAlertAction(title: "Cancel", style: .cancel) {
//            print("handle")
//        }
//        self.presentAlert(withTitle: "withTitle", message: "Message", preferredStyle: .sideBySideButtonsAlert, actions: [action])

        
//        interfaceDidScrollToTop()
//        let menuRow = tableView.rowController(at: 0) as! MenuRow
//        scroll(to: menuRow, at: .top, animated: true)
        
//        if #available(watchOSApplicationExtension 5.1, *) {
//            tableView.curvesAtBottom = true
//        }
        
//        tableView.scrollToRow(at: 1)
        
        notificationObserver = notificationCenter.addObserver(forName: NSNotification.Name("lessonsData"), object: nil, queue: nil, using: { (notification) in
//            self.hideGreeting()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
                self?.lessons = self?.storeUserDefaults.lessons ?? []
                switch self?.selectedControllerType {
                case .firstWeek:
                    self?.setFirstWeek()
                case .secondWeek:
                    self?.setSecondWeek()
                case .today:
                    self?.setToday()
                default:
                    break
                }
                self?.tableView.scrollToRow(at: 0)
            }
        })
//        let some = Numeric
                
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
//            self.tableView.scrollToRow(at: 2)
//        }


    }
    
    // MARK: - Menu functions
    
    func setFirstWeek() {
        selectedControllerType = .firstWeek
        if #available(watchOSApplicationExtension 5.1, *) {
            tableView.curvesAtBottom = false
        }

        setupTableView(week: .first)
        setInterfaceTitle("1 тиждень")
//        tableView.scrollToRow(at: 0)
    }
    
    func setSecondWeek() {
        selectedControllerType = .secondWeek

        if #available(watchOSApplicationExtension 5.1, *) {
            tableView.curvesAtBottom = false
        }
        
        setupTableView(week: .second)
        setInterfaceTitle("2 тиждень")
//        tableView.scrollToRow(at: 0)
    }
    
    func setToday() {
        selectedControllerType = .today

//        DispatchQueue.main.async {
//            if #available(watchOSApplicationExtension 5.1, *) {
////                self.tableView.scrollToRow(at: 0)
//                self.tableView.curvesAtBottom = false
//            }
//        }
//        if #available(watchOSApplicationExtension 5.1, *) {
//            tableView.curvesAtBottom = false
//        }
//        setInterfaceTitle("Сьогодні")
        self.setTitle("Сьогодні")
        setupTableViewForToday()
    }

    // MARK: - Table functions
    
    private func setupTableViewForToday() {
//        let lessonsForToday = lessons.filter { return $0.lessonWeek == currentWeekFromTodayDate && $0.dayNumber == dayNumberFromCurrentDate }
        let lessonsForToday = lessons.filter { return $0.lessonWeek == currentWeekFromTodayDate }


        selectedLessons = lessonsForToday
        selectedLessons.insert(nil, at: 0)

        
        let isEmptyLessons: Bool = lessonsForToday.count == 0 ? true : false
        
        var rowTypes: [String] = isEmptyLessons ? ["TableRow"] : Array.init(repeating: "TableRow", count: lessonsForToday.count)
        
        rowTypes.insert("TitleRow", at: 0)
        rowTypes.insert("MenuRow", at: 0)

        tableView.setRowTypes(rowTypes)


        for index in 0..<rowTypes.count {
            
            if let titleRow = tableView.rowController(at: index) as? TitleRow {
                let title = "\(DayName.getDayNameFromNumber(dayNumberFromCurrentDate)?.rawValue ?? ""), \(currentWeekFromTodayDate.rawValue) тиж."
                titleRow.titleLabel.setText(title)
            }
            
            if let tableRow = tableView.rowController(at: index) as? TableRow {
                if isEmptyLessons {
                    tableRow.lessonNameLabel.setText("Пар немає.")
                    tableRow.lessonNameLabel.setHorizontalAlignment(.center)
                    tableRow.lessonNameLabel.setVerticalAlignment(.center)
                    
                    tableRow.lessonRoomLabel.setHidden(true)
                    tableRow.timeStartLabel.setHidden(true)
                    tableRow.timeEndLabel.setHidden(true)
                    
                } else {
//                    let minusIndex = isMenuShown ? 2 : 1
                    let lesson = lessonsForToday[index - 2]
                    tableRow.lesson = lesson
                    
                    if currentLessonId == lesson.id {
                        setupCurrentOrNextLessonRow(row: tableRow, cellType: .currentCell)
                    } else if nextLessonId == lesson.id {
                        setupCurrentOrNextLessonRow(row: tableRow, cellType: .nextCell)
                    }
                }
                
            }
        }
        print("start")

        DispatchQueue.main.async { [weak self] in
            self?.tableView.scrollToRow(at: 1)
            print("scrolled")
        }
        

    }

    
    private func setupTableView(week: WeekType) {

        setupDate()
        (nextLessonId, currentLessonId) = getCurrentAndNextLesson(lessons: lessons, timeIsNowString: timeIsNowString, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
        
        
        let lessonsWeek = lessons.filter { lesson -> Bool in
            return lesson.lessonWeek == week
        }
        
        var sortedDictionary = Dictionary(grouping: lessonsWeek) { $0.dayName }
        for day in DayName.allCases {
            if sortedDictionary[day] == nil {
                sortedDictionary[day] = []
            }
        }
        
        var lessonsDictionary: [(day: DayName, lessons: [Lesson])] = []
        
        let keys = sortedDictionary.keys.sorted()
        keys.forEach { dayName in
            if let lessons: [Lesson] = sortedDictionary[dayName] {
                lessonsDictionary.append((day: dayName, lessons: lessons))
            } else {
                lessonsDictionary.append((day: dayName, lessons: []))
            }
        }

        var rowTypes: [String] = []
        
        for lessonsForSomeDay in lessonsDictionary {
            rowTypes.append("TitleRow")
            for _ in lessonsForSomeDay.lessons {
                rowTypes.append("TableRow")
            }
        }
        
        selectedLessons = []
        
        tableView.setRowTypes(rowTypes)
        var dayCounter: Int = 0
        var lessonCounter: Int = 0
            
        for index in 0..<rowTypes.count {
            if let titleRow = tableView.rowController(at: index) as? TitleRow {
                titleRow.titleLabel.setText(lessonsDictionary[dayCounter].day.rawValue)
                dayCounter += 1
                lessonCounter = 0
                selectedLessons.append(nil)
            } else if let tableRow = tableView.rowController(at: index) as? TableRow {
                let lesson = lessonsDictionary[dayCounter - 1].lessons[lessonCounter]
                tableRow.lesson = lesson
                selectedLessons.append(lesson)

                if currentLessonId == lesson.id {
                    setupCurrentOrNextLessonRow(row: tableRow, cellType: .currentCell)
                } else if nextLessonId == lesson.id {
                    setupCurrentOrNextLessonRow(row: tableRow, cellType: .nextCell)
                }
                lessonCounter += 1
            }
        }
        if #available(watchOSApplicationExtension 5.1, *) {
            tableView.curvesAtBottom = true
        }
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if selectedLessons.count > 1 {
            self.pushController(withName: "DetailedInterfaceController", context: selectedLessons[rowIndex])
        }
    }
    
    
    
    
    // MARK: - Helpers
    
    private func setInterfaceTitle(_ title: String) {
    }
    
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
    
}
