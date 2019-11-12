//
//  SheduleViewController.swift
//  kpiRozklad
//
//  Created by Denis on 9/24/19.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit
import CoreData

class SheduleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let reuseID = "reuseID"

    /// The **main** variable with which the table is updated
    var lessons: [Lesson] = []
    
    /// Variable which is copy of `lessons` but used in core data
    var lessonsCoreData: [NSManagedObject] = []
    
    /// Lessons from the first week
    var lessonsFirst: [Lesson] = []
    
    /// Lessons from the second week
    var lessonsSecond: [Lesson] = []
    
    /// Lessons from some day
    /// - todo: make easy using in tableView
    var lessonsForSomeDay: [Lesson] = []
    
    /// Copy of `lessonFirst` but used in core data
    var lessonsFirstCoreData: [NSManagedObject] = []
    
    /// Copy of `lessonsSecond` but used in core data
    var lessonsSecondCoreData: [NSManagedObject] = []
    
    /// Copy of `lessonsForSomeDay` but used in core data
    var lessonForSomeDayCoreData: [NSManagedObject] = []

    
    /**
        Сurrent week which is obtained from the date on the device
        - Remark:
            Set  up in `setUpCurrentWeek()`
     */
    var currentWeekFromTodayDate = 1
    
    /**
        Current  week which user chosed
        - Remark:
            Changed   in `weekChanged()`
            Set  up in `setUpCurrentWeek()`
     */
    var currentWeek = 1
    
    /// Week of year from date on the device
    var weekOfYear = 0
    
    /// Day number from 1 to 7
    var dayNumber = 0
    
    
    let date = Date()
    let calendar = Calendar.current
    
    /// "EEEE"  formatter (dat)
    let formatter1 = DateFormatter()
    
    /// "HH:mm"  formatter (hours and minutes)
    let formatter2 = DateFormatter()
    
    /// - todo: make time and Date normal
    var timeString = ""
    var timeDate = Date()
    var dayString = ""
    
    var currentLessonId = ""
    var nextLessonId = ""
    var nextLessonDate = Date()
    
    let colour1 = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
    let colour2 = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)

    
    @IBOutlet weak var weekSwitch: UISegmentedControl!
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        presentGroupChooser()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LessonTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "LessonTableViewCell")
        
        getDayNumAndWeekOfYear()
        setUpCurrentWeek()
        
        fetchingCoreData()
        
        // self.navigationController?.title = Settings.shared.groupName.uppercased()
        self.navigationItem.title = Settings.shared.groupName.uppercased()
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presentGroupChooser()
        print("dada")
        
        /// If Core Data is empty, making request from server
        if lessonsCoreData.isEmpty {
            server()
        } else if Settings.shared.isTryToRefreshShedule {
            deleteAllFromCoreData()
            lessonsCoreData = []
            lessons = []
            Settings.shared.isTryToRefreshShedule = false
            server()
        } else if Settings.shared.groupName == "" {
            deleteAllFromCoreData()
            lessonsCoreData = []
            lessons = []
            server()
        }
    }
    
    func presentGroupChooser() {
        if Settings.shared.groupName == "" {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let groupVC : UINavigationController = mainStoryboard.instantiateViewController(withIdentifier: "navigationGroupChooser") as! UINavigationController
            
            self.present(groupVC, animated: true, completion: nil)
        }
        
    }
    
    
    
    // MARK: - fetchingCoreData
    /// Function which fetch lesson from core data
    func fetchingCoreData() {
        /// Core data request
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LessonData")
        
        /// Getting all data from Core Data to [Datum] struct
        do {
            lessonsCoreData = try managedContext.fetch(fetchRequest)
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
                    let rate = lesson.value(forKey: "rate") as? String else { return }
                    
                /// Add data to enum  (maybe can changed)
                let dayNameCoreData = DayName(rawValue: dayName) ?? DayName(rawValue: "Понеділок")!
                let lessonTypeCoreData = LessonType(rawValue: lessonType) ?? LessonType(rawValue: "")!
                
                /// Array of teacher which added to  variable `lesson` and then added to main variable `lessons`
                var teachers: [Teacher] = []
                var rooms: [Room] = []

                
                /// Trying to fetch all Teacher Data from TeacherData entity in teachersRelationship
                if let teacherData = lesson.value(forKey: "teachersRelationship") as? TeachersData {

                    guard let teacherId = teacherData.teacherID,
                        let teacherShortName = teacherData.teacherShortName,
                        let teacherFullName = teacherData.teacherFullName,
                        let teacherURL = teacherData.teacherURL,
                        let teacherRating = teacherData.teacherRating else { return }
                    
                    let teacher = Teacher(teacherID: teacherId, teacherName: teacherName, teacherFullName: teacherFullName, teacherShortName: teacherShortName, teacherURL: teacherURL, teacherRating: teacherRating)
                    
                    teachers.append(teacher)
                }
                
                
                if let roomData = lesson.value(forKey: "roomsRelationship") as? RoomsData {

                    guard let roomID = roomData.roomID,
                        let roomName = roomData.roomName,
                        let roomLatitude = roomData.roomLatitude,
                        let roomLongitude = roomData.roomLongitude else { return }

                    let room = Room(roomID: roomID, roomName: roomName, roomLatitude: roomLatitude, roomLongitude: roomLongitude)

                    rooms.append(room)
                }
                
                
                let lesson = Lesson(lessonID: lessonID, groupID: groupID, dayNumber: dayNumber,
                                   dayName: dayNameCoreData, lessonName: lessonName, lessonFullName: lessonFullName,
                                   lessonNumber: lessonNumber, lessonRoom: lessonRoom, lessonType: lessonTypeCoreData,
                                   teacherName: teacherName, lessonWeek: lessonWeek, timeStart: timeStart,
                                   timeEnd: timeEnd, rate: rate, teachers: teachers, rooms: rooms)
                
                lessons.append(lesson)
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        /// Sorting, getting current  lessons and updatting tableView
        sortLessons()
        getCurrentAndNextLesson()
        tableView.reloadData()
    }
    
    
    // MARK: - getDayNumAndWeekOfYear
    /// Getting dayNumber and week of year from device Date()
    ///
    /// - todo: maybe use swich-case
    func getDayNumAndWeekOfYear() {
        formatter1.dateFormat = "EEEE"
        formatter2.dateFormat = "HH:mm"
        dayString = formatter1.string(from: date)
        timeString = formatter2.string(from: date)
        timeDate = formatter2.date(from: timeString) ?? Date()

        /// Get today's number in week (from 1 to 7)
        if dayString == "Monday" {
            dayNumber = 1
        } else if dayString == "Tuesday" {
            dayNumber = 2
        } else if dayString == "Wednesday" {
            dayNumber = 3
        } else if dayString == "Thursday" {
            dayNumber = 4
        } else if dayString == "Friday" {
            dayNumber = 5
        } else if dayString == "Saturday" {
            dayNumber = 6
        } else {
            dayNumber = 7
        }
        /// Get number of week (in year)
        let components = calendar.dateComponents([.weekOfYear, .month, .day, .weekday], from: date)
        weekOfYear = components.weekOfYear ?? 0
    }
    
    
    // MARK: - setUpCurrentWeek
    /// Simple function to set up currnet week in viewDidLoad
    func setUpCurrentWeek() {

        if self.weekOfYear % 2 == 0 {
            self.currentWeekFromTodayDate = 1
            self.weekSwitch.selectedSegmentIndex = 0
            self.currentWeek = 1
        } else {
            self.currentWeekFromTodayDate = 2
            self.weekSwitch.selectedSegmentIndex = 1
            self.currentWeek = 2
        }
        
    }
    
    /// - todo: make notifications
    func scheduleNotification(notificationType: String) {
        
//        let content = UNMutableNotificationContent() // Содержимое уведомления
//
//        content.title = notificationType
//        content.body = "This is example how to create " + "notificationType Notifications"
//        content.sound = UNNotificationSound.default
//        content.badge = 1
//
//
//
//        let date = Date(timeIntervalSinceNow: 10)
//        let date = formatter2.date(from: )
//        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
//
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
//
//        let identifier = "Local Notification"
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//
//        notificationCenter.add(request) { (error) in
//            if let error = error {
//                print("Error \(error.localizedDescription)")
//            }
//        }
    }
    
    // MARK: - Get data from Server
    /// Functon which getting data from server
    /// - note: This fuction call `updateCoreData()`
    /// - todo: fuction must change url for different groups
    func server() {
        let url = URL(string: "https://api.rozklad.org.ua/v2/groups/\(Settings.shared.groupID)/lessons")!
        print(url)
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()

            do {
                guard let serverFULLDATA = try? decoder.decode(WelcomeLessons.self, from: data) else { return }
                let datum = serverFULLDATA.data

                self.updateCoreData(datum: datum)
            }
        }
        task.resume()
    }
    
    // MARK:- updateCoreData
    /// Function which save all data from server in to Core data
    /// - note: Core Data for entity "Lesson"
    /// - Parameter datum: array of  [Datum] whitch received from server
    func updateCoreData(datum:  [Lesson]) {
        
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

            let managedContext = appDelegate.persistentContainer.viewContext

            for lesson in datum {
                let entity = NSEntityDescription.entity(forEntityName: "LessonData", in: managedContext)!
                let entity2 = NSEntityDescription.entity(forEntityName: "TeachersData", in: managedContext)!
                let entity3 = NSEntityDescription.entity(forEntityName: "RoomsData", in: managedContext)!


                let lessonCoreData = NSManagedObject(entity: entity, insertInto: managedContext)
                let teacherCoreData = NSManagedObject(entity: entity2, insertInto: managedContext)
                let roomCoreData = NSManagedObject(entity: entity3, insertInto: managedContext)


                lessonCoreData.setValue(lesson.lessonID, forKeyPath: "lessonID")
                lessonCoreData.setValue(lesson.groupID, forKeyPath: "groupID")
                lessonCoreData.setValue(lesson.dayNumber, forKeyPath: "dayNumber")
                lessonCoreData.setValue(lesson.dayName.rawValue, forKeyPath: "dayName")
                lessonCoreData.setValue(lesson.lessonName, forKeyPath: "lessonName")
                lessonCoreData.setValue(lesson.lessonFullName, forKeyPath: "lessonFullName")
                lessonCoreData.setValue(lesson.lessonNumber, forKeyPath: "lessonNumber")
                lessonCoreData.setValue(lesson.lessonRoom, forKeyPath: "lessonRoom")
                lessonCoreData.setValue(lesson.lessonType.rawValue, forKeyPath: "lessonType")
                lessonCoreData.setValue(lesson.teacherName, forKeyPath: "teacherName")
                lessonCoreData.setValue(lesson.lessonWeek, forKeyPath: "lessonWeek")
                lessonCoreData.setValue(lesson.timeStart, forKeyPath: "timeStart")
                lessonCoreData.setValue(lesson.timeEnd, forKeyPath: "timeEnd")
                lessonCoreData.setValue(lesson.rate, forKeyPath: "rate")
                
                if lesson.teachers.count != 0 {
                    teacherCoreData.setValue(lesson.teachers[0].teacherFullName, forKey: "teacherFullName")
                    teacherCoreData.setValue(lesson.teachers[0].teacherID, forKey: "teacherID")
                    teacherCoreData.setValue(lesson.teachers[0].teacherName, forKey: "teacherName")
                    teacherCoreData.setValue(lesson.teachers[0].teacherRating, forKey: "teacherRating")
                    teacherCoreData.setValue(lesson.teachers[0].teacherShortName, forKey: "teacherShortName")
                    teacherCoreData.setValue(lesson.teachers[0].teacherURL, forKey: "teacherURL")
                    
                    lessonCoreData.setValue(teacherCoreData, forKey: "teachersRelationship")
                }
                
                if lesson.rooms.count != 0 {
                    roomCoreData.setValue(lesson.rooms[0].roomID, forKey: "roomID")
                    roomCoreData.setValue(lesson.rooms[0].roomName, forKey: "roomName")
                    roomCoreData.setValue(lesson.rooms[0].roomLatitude, forKey: "roomLatitude")
                    roomCoreData.setValue(lesson.rooms[0].roomLongitude, forKey: "roomLongitude")

                    lessonCoreData.setValue(roomCoreData, forKey: "roomsRelationship")
                }
                
                
                do {
                    try managedContext.save()
                    self.lessonsCoreData.append(lessonCoreData)
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
            
            /// Sorting, getting current  lessons and updatting tableView
            self.sortLessons()
            self.getCurrentAndNextLesson()
            self.fetchingCoreData()
            self.tableView.reloadData()
        }
    }
    
    
    // MARK:- deleteAllFromCoreData
    /// Simple function that clear Core Data
    func deleteAllFromCoreData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LessonData")

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        // Configure Fetch Request
        fetchRequest.includesPropertyValues = false

        do {
            let managedContext = appDelegate.persistentContainer.viewContext

            let items = try managedContext.fetch(fetchRequest) as! [NSManagedObject]

            for item in items {
                managedContext.delete(item)
            }

            /// Save Changes
            try managedContext.save()

        } catch {
            /// Error Handling
        }
    }
    
    
    // MARK:- weekChanged
    /// Function that calls when the user tap on segment conrol to change current week
    @IBAction func weekChanged(_ sender: UISegmentedControl) {
        switch weekSwitch.selectedSegmentIndex {
            case 0:
                currentWeek = 1
                tableView.reloadData()
            case 1:
                currentWeek = 2
                tableView.reloadData()
            default:
                break
        }
    }
    
    
    // MARK:- sortLessons
    /// Sorting lessons by week
    func sortLessons() {
        lessonsFirst = []
        lessonsSecond = []
        
        for lesson in lessons {
            if Int(lesson.lessonWeek) == 1 {
                lessonsFirst.append(lesson)
            } else {
                lessonsSecond.append(lesson)
            }
        }
    }
    
    
    // MARK:- getCurrentAndNextLesson
    /// Function that makes current lesson **orange** and next lesson **blue**
    /// - todo: make some with time and Date
    func getCurrentAndNextLesson() {
        for lesson in lessons {
            let timeStartString = lesson.timeStart
            let substringTimeStart = String(timeStartString[..<5])
            let timeEndString = lesson.timeEnd
            let substringTimeEnd = String(timeEndString[..<5])
            
            let timeStart = formatter2.date(from:substringTimeStart) ?? Date()
            let timeEnd = formatter2.date(from:substringTimeEnd) ?? Date()
            
            if  ((timeStart <= timeDate) &&
                (timeDate < timeEnd) &&
                (dayNumber == Int(lesson.dayNumber)) &&
                (currentWeekFromTodayDate == Int(lesson.lessonWeek) ?? 0)) {
                
                currentLessonId = lesson.lessonID
            }
        }
        
        for lesson in lessons {
            let timeStartString = lesson.timeStart
            let substringTimeStart = String(timeStartString[..<5])
            let timeStart = formatter2.date(from:substringTimeStart) ?? Date()
            
            if (timeStart > timeDate) && (dayNumber == Int(lesson.dayNumber) ?? 0) && (currentWeekFromTodayDate == Int(lesson.lessonWeek) ?? 0) {
                nextLessonId = lesson.lessonID
                break
            } else if (dayNumber < Int(lesson.dayNumber) ?? 0) && (currentWeekFromTodayDate == Int(lesson.lessonWeek) ?? 0){
                nextLessonId = lesson.lessonID
                break
            }
        }
        
        if lessonsFirst.count != 0 && lessonsSecond.count != 0 {
            if nextLessonId == "" && currentWeekFromTodayDate == 2 {
                nextLessonId = lessonsFirst[0].lessonID
            } else if nextLessonId == "" && currentWeekFromTodayDate == 1 {
                nextLessonId = lessonsSecond[0].lessonID
            }
        }
    }


}


// MARK: - Table View Settings
extension SheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    

    /// TitleForHeaderInSections
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let mounday = "Понеділок"
        let tuesday = "Вівторок"
        let wednesday = "Середа"
        let thursday = "Четвер"
        let friday = "П’ятниця"

        let array: [String] = [mounday, tuesday, wednesday, thursday, friday]
        
        return array[section]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentLessonWeek = currentWeek == 1 ? lessonsFirst : lessonsSecond
        
        var countMounday = 0
        var countTuesday = 0
        var countWednesday = 0
        var countThursday = 0
        var countFriday = 0
        
        // TODO: check how swich-case works and maybe use it
        for datu in currentLessonWeek {
            if datu.dayName.rawValue == "Понеділок" {
                countMounday += 1
            } else if datu.dayName.rawValue == "Вівторок"{
                countTuesday += 1
            } else if datu.dayName.rawValue == "Середа"{
                countWednesday += 1
            } else if datu.dayName.rawValue == "Четвер"{
                countThursday += 1
            } else if datu.dayName.rawValue == "П’ятниця"{
                countFriday += 1
            }
        }
        
        let array: [Int] = [countMounday, countTuesday, countWednesday, countThursday, countFriday]
        return array[section]
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailViewController" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let destination = segue.destination as? SheduleDetailViewController {
                    lessonsForSomeDay = []
                    if currentWeek == 1 {
                        for lesson in lessonsFirst {
                            if Int(lesson.dayNumber) == (indexPath.section + 1) {
                                lessonsForSomeDay.append(lesson)
                            }
                        }
                    } else {
                        for lesson in lessonsSecond {
                            if Int(lesson.dayNumber) == (indexPath.section + 1) {
                                lessonsForSomeDay.append(lesson)
                            }
                        }
                    }
                    destination.lesson = lessonsForSomeDay[indexPath.row]
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard (storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? SheduleDetailViewController) != nil else { return }
        performSegue(withIdentifier: "showDetailViewController", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LessonTableViewCell", for: indexPath) as? LessonTableViewCell else {return UITableViewCell()}
        
        lessonsForSomeDay = []
        
        if currentWeek == 1 {
            for lesson in lessonsFirst {
                if Int(lesson.dayNumber) == (indexPath.section + 1) {
                    lessonsForSomeDay.append(lesson)
                }
            }
        } else {
            for lesson in lessonsSecond {
                if Int(lesson.dayNumber) == (indexPath.section + 1) {
                    lessonsForSomeDay.append(lesson)
                }
            }
        }
        
        cell.lessonLabel.text = lessonsForSomeDay[indexPath.row].lessonName
        cell.teacherLabel.text = lessonsForSomeDay[indexPath.row].teacherName
        
        if lessonsForSomeDay[indexPath.row].teacherName == "" {
            let nothing = " "
            cell.teacherLabel.text = nothing
        }

        
        if currentLessonId == lessonsForSomeDay[indexPath.row].lessonID {
            cell.backgroundColor = .orange
        }
        
        if nextLessonId == lessonsForSomeDay[indexPath.row].lessonID {
            cell.backgroundColor = colour1
        }
        
    
        
        let timeStartString = lessonsForSomeDay[indexPath.row].timeStart
        let substringTimeStart = String(timeStartString[..<5])
        
        let timeEndString = lessonsForSomeDay[indexPath.row].timeEnd
        let substringTimeEnd = String(timeEndString[..<5])
        
        cell.startLabel.text = substringTimeStart
        cell.endLabel.text = substringTimeEnd
        cell.roomLabel.text = lessonsForSomeDay[indexPath.row].lessonType.rawValue + " " + lessonsForSomeDay[indexPath.row].lessonRoom
        
        return cell
    }
}
