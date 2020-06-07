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
    
    /// Array with lessons used for CoreData
    var lessons: [Lesson] = []
    
    /**
     The **main** variable by which the table view is updated
    */
    var lessonsForTableView: [(key: DayName, value: [Lesson])] = []
    
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
    
    var countDeleteLessons = 0
    
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
            let height = lessonsForTableView[dayNumberFromCurrentDate - 1].value.count * 68
            self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: CGFloat(height))
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
        
        if self.weekOfYear % 2 == 0 {
            self.currentWeekFromTodayDate = 1
        } else {
            self.currentWeekFromTodayDate = 2
        }
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
                var height = lessonsForTableView[dayNumberFromCurrentDate - 1].value.count * 68
                if height == 0 {
                    height = 110
                }
                self.preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(height))
            }
        }
    }
    
    
    // MARK: - Core Data functions
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSCustomPersistentContainer(name: "kpiRozklad")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
//    func fetchingCoreData() -> [Lesson] {
//
//        let managedContext = self.persistentContainer.viewContext
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LessonData")
//
//        var lessonsArray: [Lesson] = []
//
//        do {
//            guard let fetchResult = try managedContext.fetch(fetchRequest) as? [LessonData] else { return [] }
//
//            for lessonData in fetchResult {
//
//                var roomsArray: [Room] = []
//                let room: Room?
//
//                if let roomData = lessonData.roomsRelationship {
//                    room = Room(roomID: roomData.roomID ?? "",
//                                roomName: roomData.roomName ?? "",
//                                roomLatitude: roomData.roomLatitude ?? "",
//                                roomLongitude: roomData.roomLongitude ?? "")
//
//                    if let room = room {
//                        roomsArray.append(room)
//                    }
//                }
//
//
//                var teachersArray: [Teacher] = []
//                let teacher: Teacher?
//
//                if let teacherData = lessonData.teachersRelationship {
//                    teacher = Teacher(teacherID: teacherData.teacherID ?? "",
//                                      teacherName: teacherData.teacherName ?? "",
//                                      teacherFullName: teacherData.teacherFullName ?? "",
//                                      teacherShortName: teacherData.teacherShortName ?? "",
//                                      teacherURL: teacherData.teacherURL ?? "",
//                                      teacherRating: teacherData.teacherRating ?? "")
//
//                    if let teacher = teacher {
//                        teachersArray.append(teacher)
//                    }
//                }
//
//
//                var groupsArray: [Group] = []
//
//                if let groupsDataArray = lessonData.groupsRelationship?.allObjects as? [GroupData] {
//                    for groupData in groupsDataArray {
//                        let group = Group(groupID: Int(groupData.groupID),
//                                          groupFullName: groupData.groupFullName ?? "",
//                                          groupPrefix: groupData.groupFullName ?? "",
//                                          groupOkr: GroupOkr(rawValue: groupData.groupOkr ?? "") ?? GroupOkr.bachelor,
//                                          groupType: GroupType(rawValue: groupData.groupType ?? "") ?? GroupType.daily,
//                                          groupURL: groupData.groupURL ?? "")
//
//                        groupsArray.append(group)
//                    }
//                }
//
//
//                let lesson = Lesson(lessonID: lessonData.lessonID ?? "",
//                                    dayNumber: lessonData.dayNumber ?? "",
//                                    groupID: lessonData.groupID ?? "",
//                                    dayName: DayName(rawValue: lessonData.dayName ?? "") ?? DayName.mounday,
//                                    lessonName: lessonData.lessonName ?? "",
//                                    lessonFullName: lessonData.lessonFullName ?? "",
//                                    lessonNumber: lessonData.lessonNumber ?? "",
//                                    lessonRoom: lessonData.lessonRoom ?? "",
//                                    lessonType: LessonType(rawValue: lessonData.lessonType ?? "") ?? LessonType.empty,
//                                    teacherName: lessonData.teacherName ?? "",
//                                    lessonWeek: lessonData.lessonWeek ?? "",
//                                    timeStart: lessonData.timeStart ?? "",
//                                    timeEnd: lessonData.timeEnd ?? "",
//                                    rate: lessonData.rate ?? "",
//                                    teachers: teachersArray,
//                                    rooms: roomsArray,
//                                    groups: groupsArray)
//
//                lessonsArray.append(lesson)
//            }
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//
//        return lessonsArray
//    }

    
    func makeLessonsShedule() {
        /// fetching Core Data
        let lessons: [Lesson] = fetchingCoreData(managedContext: persistentContainer.viewContext)
        
        setupDate()
        (nextLessonId, currentLessonId) = getCurrentAndNextLesson(lessons: lessons, timeIsNowString: timeIsNowString, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)


        /// Getting lesson for first week and second
        var lessonsFirst: [Lesson] = []
        var lessonsSecond: [Lesson] = []
        
        for lesson in lessons {
            if Int(lesson.lessonWeek) == 1 {
                lessonsFirst.append(lesson)
            } else {
                lessonsSecond.append(lesson)
            }
        }
        
        /// Choosing lesson from currnetWeek
        let currentLessonWeek = currentWeekFromTodayDate == 1 ? lessonsFirst : lessonsSecond
        
        var lessonMounday: [Lesson] = []
        var lessonTuesday: [Lesson] = []
        var lessonWednesday: [Lesson] = []
        var lessonThursday: [Lesson] = []
        var lessonFriday: [Lesson] = []
        var lessonSaturday: [Lesson] = []
        
        for datu in currentLessonWeek {
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
        
        /// Sorting all
        lessonMounday.sort { (lesson1, lesson2) -> Bool in
            return lesson1.lessonNumber < lesson2.lessonNumber
        }
        
        lessonTuesday.sort { (lesson1, lesson2) -> Bool in
            return lesson1.lessonNumber < lesson2.lessonNumber
        }
        
        lessonWednesday.sort { (lesson1, lesson2) -> Bool in
            return lesson1.lessonNumber < lesson2.lessonNumber
        }
        
        lessonThursday.sort { (lesson1, lesson2) -> Bool in
            return lesson1.lessonNumber < lesson2.lessonNumber
        }
        
        lessonFriday.sort { (lesson1, lesson2) -> Bool in
            return lesson1.lessonNumber < lesson2.lessonNumber
        }
        
        lessonSaturday.sort { (lesson1, lesson2) -> Bool in
            return lesson1.lessonNumber < lesson2.lessonNumber
        }
        
        /// .sorting is soting from mounday to saturday (must be in normal order)
        self.lessonsForTableView = [DayName.mounday: lessonMounday,
                                    .tuesday: lessonTuesday,
                                    .wednesday: lessonWednesday,
                                    .thursday: lessonThursday,
                                    .friday: lessonFriday,
                                    .saturday: lessonSaturday].sorted{$0.key < $1.key}
        
        /// (self.tableView != nil)  because if when we push information from another VC tableView can be not exist
        if self.tableView != nil {
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
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
            return 1
        } else if self.lessonsForTableView[dayNumberFromCurrentDate - 1].value.count != 0 {
            return self.lessonsForTableView[dayNumberFromCurrentDate - 1].value.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var id = ""
        
        if dayNumberFromCurrentDate == 7 {
            id = ""
        } else if lessonsForTableView[dayNumberFromCurrentDate - 1].value.count == 0 {
            id = ""
        } else {
            id = lessonsForTableView[dayNumberFromCurrentDate - 1].value[indexPath.row].lessonID
        }

        let url: URL? = URL(string: "kpiRozklad://\(id)")!
        
        if let appurl = url {
            self.extensionContext!.open(appurl,
                completionHandler: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LessonTableViewCell.identifier, for: indexPath) as? LessonTableViewCell else { return UITableViewCell() }
        
        var lessonsForSomeDay: [Lesson] = []
        
        if dayNumberFromCurrentDate != 7 {
            lessonsForSomeDay = lessonsForTableView[dayNumberFromCurrentDate - 1].value
        }
        
        if lessonsForSomeDay.count == 0 {
            isLessonsEnd = true
        }
        
        if isLessonsEnd {
            cell.lessonLabel.text = "Пари закінчилися."
            cell.teacherLabel.text = ""
            cell.timeLeftLabel.text = ""
            cell.endLabel.text = ""
            cell.startLabel.text = ""
            cell.roomLabel.text = ""
            return cell
        }
        
        cell.lessonLabel.text = lessonsForSomeDay[indexPath.row].lessonName
        cell.teacherLabel.text = lessonsForSomeDay[indexPath.row].teacherName
        
        if lessonsForSomeDay[indexPath.row].teacherName == "" {
            cell.teacherLabel.text = " "
        }

        
        if currentLessonId == lessonsForSomeDay[indexPath.row].lessonID {
            setupCurrentOrNextLessonCell(cell: cell, cellType: .currentCell)
        }

        if nextLessonId == lessonsForSomeDay[indexPath.row].lessonID {
            setupCurrentOrNextLessonCell(cell: cell, cellType: .nextCell)
        }
        
        let timeStart = String(lessonsForSomeDay[indexPath.row].timeStart[..<5])
        
        let timeEnd = String(lessonsForSomeDay[indexPath.row].timeEnd[..<5])
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "HH"
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "mm"
        
        let currentDate = Date()
        let dateStart = formatter.date(from: timeStart) ?? Date()
        let dateEnd = formatter.date(from: timeEnd) ?? Date()

        let nowH = formatter1.string(from: currentDate)
        let nowM = formatter2.string(from: currentDate)
        
        let startH = formatter1.string(from: dateStart)
        let startM = formatter2.string(from: dateStart)
        
        var leftH = (Int(startH) ?? 0) - (Int(nowH) ?? 0)
        var leftM = (Int(startM) ?? 0) - (Int(nowM) ?? 0)
        
        if leftM < 0 && leftH >= 1 {
            leftH -= 1
            leftM = 60 + leftM
        }
        
        if leftH < 0 || leftM < 0 {
            leftH = 0
            leftM = 0
        }

        var dateString = ""
        
        if leftH == 0 && leftM == 0 {
            let endH = formatter1.string(from: dateEnd)
            let endM = formatter2.string(from: dateEnd)
            
            leftH = (Int(endH) ?? 0) - (Int(nowH) ?? 0)
            leftM = (Int(endM) ?? 0) - (Int(nowM) ?? 0)
            
            if leftM < 0 && leftH >= 1 {
                leftH -= 1
                leftM = 60 + leftM
            }
            if leftH < 0 || leftM < 0 {
                dateString = " "
                lessonsForTableView[dayNumberFromCurrentDate - 1].value.removeFirst()
                if lessonsForTableView[dayNumberFromCurrentDate - 1].value.count == 0 {
                    isLessonsEnd = true
                    cell.lessonLabel.text = "На сьогодні все"
                    cell.timeLeftLabel.text = ""
                    cell.endLabel.text = ""
                    cell.startLabel.text = ""
                    cell.roomLabel.text = ""
                }
                setupHeight()
                tableView.reloadData()
                return cell
            } else {
                
                if leftH == 0 {
                    dateString = "залишилось \(leftM) хв"
                } else if leftM == 0 {
                    dateString = "залишилось \(leftH) год"
                } else {
                    dateString = "залишилось \(leftH) год, \(leftM) хв"
                }
                
            }
        } else {
            if leftH == 0 {
                dateString = "через \(leftM) хв"
            } else if leftM == 0 {
                dateString = "через \(leftH) год"
            } else {
                dateString = "через \(leftH) год, \(leftM) хв"
            }
            
        }
        
        cell.startLabel.text = timeStart
        cell.endLabel.text = timeEnd
        cell.roomLabel.text = lessonsForSomeDay[indexPath.row].lessonType.rawValue + " " + lessonsForSomeDay[indexPath.row].lessonRoom
        
        cell.timeLeftLabel.text = dateString
        
        return cell
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
