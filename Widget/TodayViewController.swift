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
    @IBOutlet weak var tableView: UITableView!
    var lessons: [Lesson] = []
    var lessonsForTableView: [(key: DayName, value: [Lesson])] = []
    
    var currentWeekFromTodayDate = 1
    
    /**
        Current  week which user chosed
        - Remark:
            Changed   in `weekChanged()`
            Set  up in `setUpCurrentWeek()`
     */
//    var currentWeek = 1
    
    /// Week of year from date on the device
    var weekOfYear = 0
    
    /// Day number from 1 to 7
    var dayNumberFromCurrentDate = 0
    
    /// Time is Now from device
    var timeIsNowString = String()
    
    /// Lesson ID of **current** Lesson
    ///- Remark:
    ///     Set  up in `getCurrentAndNextLesson(lessons: [Lesson])`
    var currentLessonId = String()
    
    /// Lesson ID of **next** Lesson
    ///- Remark:
    ///     Set  up in `getCurrentAndNextLesson(lessons: [Lesson])`
    var nextLessonId = String()
    
    /// Colour of next lesson
    let colour1 = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 0.748046875)
    
    var countDeleteLessons = 0
    
    var isLessonsEnd: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        setupDate()
        setupTableView()

        makeLessonsShedule(lessonsInit: nil)
        
        setupHeight()

        
    }
        
    func setupHeight() {
        let height = lessonsForTableView[dayNumberFromCurrentDate - 1].value.count * 68
        
        self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: CGFloat(height))
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    

    
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = CGSize(width: maxSize.width, height: maxSize.height)
        } else if activeDisplayMode == .expanded {
            let height = lessonsForTableView[dayNumberFromCurrentDate - 1].value.count * 68
            self.preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(height))
        }
    }
    
    private func setupTableView() {
            tableView.register(UINib(nibName: LessonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: LessonTableViewCell.identifier)
            tableView.delegate = self
            tableView.dataSource = self
    //        var insetsContentViewsToSafeArea: Bool = true
    //        tableView.insetsContentViewsToSafeArea = false

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
    
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSCustomPersistentContainer(name: "kpiRozklad")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func fetchingCoreData() -> [Lesson] {
        /// Core data request

        let managedContext = self.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LessonData")
        
        var lessons: [Lesson] = []
        
        /// Getting all data from Core Data to [Lesson] struct
        do {
            let lessonsCoreData = try managedContext.fetch(fetchRequest)
            lessons = []
            
            for lesson in lessonsCoreData {
                
                guard let lessonID = lesson.value(forKey: "lessonID") as? String,
                    let groupID = lesson.value(forKey: "groupID") as? String,
                    let dayNumber = lesson.value(forKey: "dayNumber") as? String,
                    let dayName = lesson.value(forKey: "dayName") as? String,
                    let lessonType = lesson.value(forKey: "lessonType") as? String,
                    let lessonName = lesson.value(forKey: "lessonName") as? String,
                    let lessonFullName = lesson.value(forKey: "lessonFullName") as? String,
                    let lessonNumber = lesson.value(forKey: "lessonNumber") as? String,
                    let lessonRoom = lesson.value(forKey: "lessonRoom") as? String,
                    let teacherName = lesson.value(forKey: "teacherName") as? String,
                    let lessonWeek = lesson.value(forKey: "lessonWeek") as? String,
                    let timeStart = lesson.value(forKey: "timeStart") as? String,
                    let timeEnd = lesson.value(forKey: "timeEnd") as? String,
                    let rate = lesson.value(forKey: "rate") as? String else { return [] }
                    
                /// Add data to enum  (maybe can changed)
                let dayNameCoreData = DayName(rawValue: dayName) ?? DayName.mounday
                let lessonTypeCoreData = LessonType(rawValue: lessonType) ?? LessonType.empty
                
                
                /// Array of teacher which added to  variable `lesson` and then added to main variable `lessons`
                var teachers: [Teacher] = []
                
                /// Trying to fetch all Teacher Data from TeacherData entity in teachersRelationship
                if let teacherData = lesson.value(forKey: "teachersRelationship") as? TeachersData {

                    guard let teacherId = teacherData.teacherID,
                        let teacherShortName = teacherData.teacherShortName,
                        let teacherFullName = teacherData.teacherFullName,
                        let teacherURL = teacherData.teacherURL,
                        let teacherRating = teacherData.teacherRating else { return []}
                    
                    let teacher = Teacher(teacherID: teacherId, teacherName: teacherName, teacherFullName: teacherFullName, teacherShortName: teacherShortName, teacherURL: teacherURL, teacherRating: teacherRating)
                    
                    teachers.append(teacher)
                }
                
                
                /// Array of rooms which added to  variable `lesson` and then added to main variable `lessons`
                var rooms: [Room] = []
                
                if let roomData = lesson.value(forKey: "roomsRelationship") as? RoomsData {

                    guard let roomID = roomData.roomID,
                        let roomName = roomData.roomName,
                        let roomLatitude = roomData.roomLatitude,
                        let roomLongitude = roomData.roomLongitude else { return []}

                    let room = Room(roomID: roomID, roomName: roomName, roomLatitude: roomLatitude, roomLongitude: roomLongitude)

                    rooms.append(room)
                }
                
                /// Creating `Lesson`
                let lesson = Lesson(lessonID: lessonID, dayNumber: dayNumber, groupID: groupID,
                                   dayName: dayNameCoreData, lessonName: lessonName, lessonFullName: lessonFullName,
                                   lessonNumber: lessonNumber, lessonRoom: lessonRoom, lessonType: lessonTypeCoreData,
                                   teacherName: teacherName, lessonWeek: lessonWeek, timeStart: timeStart,
                                   timeEnd: timeEnd, rate: rate, teachers: teachers, rooms: rooms, groups: [])
                
                lessons.append(lesson)
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        
        return lessons
    }
    
    
    
    
    func makeLessonsShedule(lessonsInit: [Lesson]?) {
        /// fetching Core Data
        var lessons: [Lesson] = []
        lessons = fetchingCoreData()
        setupDate()
        let currentAndNext = getCurrentAndNextLesson(lessons: lessons, timeIsNowString: timeIsNowString, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
        
        currentLessonId = currentAndNext.currentLessonID
        nextLessonId = currentAndNext.nextLessonID


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
        
        /// (self.activityIndicator != nil)  because if when we push information from another VC tableView can be not exist
        
        /// (self.tableView != nil)  because if when we push information from another VC tableView can be not exist
        if self.tableView != nil {
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    
    
    
    
}

extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dayNumberFromCurrentDate == 7 {
            return 0
        } else if isLessonsEnd {
            return 1
        } else {
            return self.lessonsForTableView[dayNumberFromCurrentDate - 1].value.count - countDeleteLessons
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let url: URL? = URL(string: "kpiRozklad:")!
//
//        if let appurl = url {
//            self.extensionContext!.open(appurl,
//                completionHandler: nil)
//        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LessonTableViewCell.identifier, for: indexPath) as? LessonTableViewCell else { return UITableViewCell() }
        
        let lessonsForSomeDay = lessonsForTableView[dayNumberFromCurrentDate - 1].value
        
        if isLessonsEnd {
            cell.lessonLabel.text = "На сьогодні все."
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
            cell.backgroundColor = #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 0.85)
        }

        if nextLessonId == lessonsForSomeDay[indexPath.row].lessonID {
            cell.backgroundColor = colour1
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
//                countDeleteLessons += 1
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
    
    
}
