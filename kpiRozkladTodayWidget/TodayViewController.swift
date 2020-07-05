//
//  TodayViewController.swift
//  Widget
//
//  Created by Денис Данилюк on 07.02.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit
import CoreData
import NotificationCenter



class TodayViewController: UIViewController, NCWidgetProviding {
    
    /// Main table view
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Core Data functions
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSCustomPersistentContainer(name: "kpiRozkladModel")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    /// Array with lessons used for CoreData
    var lessons: [Lesson] = []
    
    /**
     The **main** variable by which the table view is updated
    */
    var lessonsForTableView: [(day: DayName, lessons: [Lesson])] = [(day: DayName.mounday, lessons: []),
                                                                    (day: DayName.tuesday, lessons: []),
                                                                    (day: DayName.wednesday, lessons: []),
                                                                    (day: DayName.thursday, lessons: []),
                                                                    (day: DayName.friday, lessons: []),
                                                                    (day: DayName.saturday, lessons: [])]
    
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
    
    
    var isLessonsEnd: Bool = false


    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        setupDate()
        setupTableView()
        makeLessonsShedule()
        setupHeight()
    }
        
    
    // MARK: - SETUP functions

    func setupHeight() {
        if dayNumberFromCurrentDate != 7 {
            let height = lessonsForTableView[dayNumberFromCurrentDate - 1].lessons.count * 68
            self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: CGFloat(height))
        } else {
            self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 110)
        }
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: LessonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: LessonTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupDate() {
        let result = getTimeAndDayNumAndWeekOfYear()
        timeIsNowString = result.timeIsNowString
        dayNumberFromCurrentDate = result.dayNumberFromCurrentDate
        weekOfYear = result.weekOfYear
        
        self.currentWeekFromTodayDate = self.weekOfYear % 2 == 0 ? .first : .second
    }
    
    
    // MARK: - widget functions
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = CGSize(width: maxSize.width, height: maxSize.height)
        } else if activeDisplayMode == .expanded {
            if dayNumberFromCurrentDate != 7 {
                var height = lessonsForTableView[dayNumberFromCurrentDate - 1].lessons.count * 68
                if height == 0 {
                    height = 110
                }
                self.preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(height))
            }
        }
    }
    
    func makeLessonsShedule() {
        /// fetching Core Data
        let lessons: [Lesson] = fetchingCoreData(managedContext: persistentContainer.viewContext)
        
        setupDate()
        (nextLessonId, currentLessonId) = getCurrentAndNextLesson(lessons: lessons, timeIsNowString: timeIsNowString, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)


        /// Getting lesson for first week and second
        let lessonsFirst: [Lesson] = lessons.filter { $0.lessonWeek == .first }
        let lessonsSecond: [Lesson] = lessons.filter { $0.lessonWeek == .second }
        let currentLessonWeek = currentWeekFromTodayDate == .first ? lessonsFirst : lessonsSecond
        
        var sortedDictionary = Dictionary(grouping: currentLessonWeek) { $0.dayName }
        for day in DayName.allCases {
            if sortedDictionary[day] == nil {
                sortedDictionary[day] = []
            }
        }
        
        var result: [(day: DayName, lessons: [Lesson])] = []
        
        let keys = sortedDictionary.keys.sorted()
        keys.forEach { dayName in
            if let lessons: [Lesson] = sortedDictionary[dayName] {
                result.append((day: dayName, lessons: lessons))
            } else {
                result.append((day: dayName, lessons: []))
            }
        }
        self.lessonsForTableView = result
    }

}


// MARK: - UITableViewDelegate + DataSource
extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLessonsEnd {
            return 110
        } else {
            return 68
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLessonsEnd || dayNumberFromCurrentDate == 7 {
            print("here 1")
            return 1
        } else if self.lessonsForTableView[dayNumberFromCurrentDate - 1].lessons.count != 0 {
            print(self.lessonsForTableView[dayNumberFromCurrentDate - 1].lessons.count)
            return self.lessonsForTableView[dayNumberFromCurrentDate - 1].lessons.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var id: Int = 0

        if dayNumberFromCurrentDate != 7 && lessonsForTableView[dayNumberFromCurrentDate - 1].lessons.count != 0 {
            id = lessonsForTableView[dayNumberFromCurrentDate - 1].lessons[indexPath.row].id
        }

        let url: URL? = URL(string: "kpiRozklad://\(id)")!
        
        if let appurl = url {
            self.extensionContext!.open(appurl) { (success) in
                if (!success) {
                    print("error: failed to open app from Today Extension")
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func makeEmptyCell(_ cell: LessonTableViewCell) {
        cell.lessonLabel.text = "Пари закінчилися."
        cell.teacherLabel.text = ""
        cell.timeLeftLabel.text = ""
        cell.endLabel.text = ""
        cell.startLabel.text = ""
        cell.roomLabel.text = ""
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LessonTableViewCell.identifier, for: indexPath) as? LessonTableViewCell else { return UITableViewCell() }
        
        var lessonsForSomeDay: [Lesson] = []

        if dayNumberFromCurrentDate == 7 || isLessonsEnd || lessonsForTableView[dayNumberFromCurrentDate - 1].lessons.count == 0 {
            isLessonsEnd = true
            makeEmptyCell(cell)
            return cell
        } else {
            lessonsForSomeDay = lessonsForTableView[dayNumberFromCurrentDate - 1].lessons
        }

        let lesson = lessonsForSomeDay[indexPath.row]
        
        let timeStart = lesson.timeStart.stringTime
        let timeEnd = lesson.timeEnd.stringTime
        
        let dateNow = Date()

        let formatterFull = DateFormatter()
        formatterFull.dateFormat = "YYYY:MM:DD:HH:mm"

        let formatterInWhichTimeSaved = DateFormatter()
        formatterInWhichTimeSaved.dateFormat = "YYYY:MM:DD"
        let fullYearMonthDay = formatterInWhichTimeSaved.string(from: dateNow)

        let dateStartInit = formatterFull.date(from: "\(fullYearMonthDay):\(timeStart)") ?? Date()
        let dateEndInit = formatterFull.date(from: "\(fullYearMonthDay):\(timeEnd)") ?? Date()

        let toStartPair = dateStartInit.timeIntervalSince1970 - dateNow.timeIntervalSince1970
        let toEndPair = dateEndInit.timeIntervalSince1970 - dateNow.timeIntervalSince1970
        
        var dateToPrint: String = ""
        if toStartPair > 60 {
            dateToPrint = "через \(timeIntervalToString(toStartPair))"
        } else if toStartPair > 0 {
            dateToPrint = "менше 1хв"
        } else if toEndPair > 60 {
            dateToPrint = "залишилось \(timeIntervalToString(toEndPair))"
        } else if toEndPair > 0 {
            dateToPrint = "залишилось менше 1хв"
        }
        
        if toEndPair < 0 {
            lessonsForTableView[dayNumberFromCurrentDate - 1].lessons.removeFirst()
            if lessonsForTableView[dayNumberFromCurrentDate - 1].lessons.count == 0 {
                isLessonsEnd = true
            }
            setupHeight()
            tableView.reloadData()

            return cell
        }
        
        if currentLessonId == lessonsForSomeDay[indexPath.row].id {
            setupCurrentOrNextLessonCell(cell: cell, cellType: .currentCell)
        } else if nextLessonId == lessonsForSomeDay[indexPath.row].id {
            setupCurrentOrNextLessonCell(cell: cell, cellType: .nextCell)
        }
        
        cell.lessonLabel.text = lesson.lessonName
        cell.teacherLabel.text = lesson.teacherName
        cell.startLabel.text = timeStart
        cell.endLabel.text = timeEnd
        cell.roomLabel.text = lesson.lessonType.rawValue + " " + lessonsForSomeDay[indexPath.row].lessonRoom
        cell.timeLeftLabel.text = dateToPrint
        
        return cell
    }
    
    func timeIntervalToString(_ timeInterval: TimeInterval) -> String {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "uk")
        
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        
        guard let formattedString = formatter.string(from: timeInterval) else { return "" }
        return formattedString
    }
    
    public func setupCurrentOrNextLessonCell(cell: LessonTableViewCell, cellType: SheduleCellType) {
        
        if cellType == .currentCell {
            cell.backgroundColor = Settings.shared.cellCurrentColour
        } else if cellType == .nextCell {
            cell.backgroundColor = Settings.shared.cellNextColour
        }
        
        let textColour: UIColor = cell.backgroundColor?.isWhiteText ?? true ? .white : .black
        
        cell.startLabel.textColor = textColour
        cell.endLabel.textColor = textColour
        cell.teacherLabel.textColor = textColour
        cell.roomLabel.textColor = textColour
        cell.lessonLabel.textColor = textColour
        cell.timeLeftLabel.textColor = textColour
    }
}
