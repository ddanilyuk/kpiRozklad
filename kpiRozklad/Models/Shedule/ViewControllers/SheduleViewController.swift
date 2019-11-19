//
//  SheduleViewController.swift
//  kpiRozklad
//
//  Created by Denis on 9/24/19.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit
import CoreData

/// Some about how it works
///
/// ## Important things ##
///
/// 1. All in table view works with `lessonsForTableView` variable, but Core Data saving `[Lesson]`
/// 2. `makeLessonsShedule()` remake `[Lesson]` to `[(key: DayName, value: [Lesson])]`
/// 3. `server()` call `updateCoreData(datum:  [Lesson])` where datum is `[Lesson]` from API
/// 4. `fetchingCoreData() -> [Lesson]` return `[Lesson]` from Core Data
class SheduleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    /// ReuseID for tableView
    let reuseID = "reuseID"

    /// The **main** variable with which the table is updated
    var lessonsForTableView: [(key: DayName, value: [Lesson])] = []
    
    /// Variable which is copy of `lessons` but used in core data
    var lessonsCoreData: [NSManagedObject] = []
    
    
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

    /// Week switcher (1 and 2 week)
    @IBOutlet weak var weekSwitch: UISegmentedControl!
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Button `Edit`
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        
        presentGroupChooser()
        

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LessonTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "LessonTableViewCell")
        
        getDayNumAndWeekOfYear()
        setUpCurrentWeek()
        
        makeLessonsShedule()
        
        self.navigationItem.title = Settings.shared.groupName.uppercased()
    }
    
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        presentGroupChooser()
        
        /// If Core Data is empty, making request from server
        if lessonsCoreData.isEmpty || Settings.shared.isTryToRefreshShedule {
            deleteAllFromCoreData()
            lessonsCoreData = []
            Settings.shared.isTryToRefreshShedule = false
            server()
            self.tableView.reloadData()
        }
        
        /// Reloading tableView if need
        if Settings.shared.isTryToReloadTableView {
            makeLessonsShedule()
            tableView.reloadData()
            Settings.shared.isTryToReloadTableView = false
        }
    }
    
    
    // MARK: - presentGroupChooser
    /// Func which present `GroupChooserViewController` (navigationGroupChooser)
    /// - todo: maybe delete if
    func presentGroupChooser() {
        if Settings.shared.groupName == "" {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let navigationGroupChooser : UINavigationController = mainStoryboard.instantiateViewController(withIdentifier: "navigationGroupChooser") as! UINavigationController
            deleteAllFromCoreData()
            lessonsCoreData = []
            self.present(navigationGroupChooser, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - presentAddLesson
    /// Func which present `AddLessonViewController`
    func presentAddLesson() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let addLesson : AddLessonViewController = mainStoryboard.instantiateViewController(withIdentifier: "addLesson") as! AddLessonViewController

        addLesson.lessons = self.fetchingCoreData()
        addLesson.currentWeek = self.currentWeek
        self.present(addLesson, animated: true, completion: nil)
    }
    
    
    // MARK: - getDayNumAndWeekOfYear
    /// Getting dayNumber and week of year from device Date()
    ///
    /// - todo: maybe use swich-case
    func getDayNumAndWeekOfYear() {
        formatter1.dateFormat = "EEEE"
        formatter2.dateFormat = "HH:mm"
        dayString = formatter1.string(from: date).lowercased()
        timeString = formatter2.string(from: date)
        timeDate = formatter2.date(from: timeString) ?? Date()

        /// Get today's number in week (from 1 to 7)
        if dayString == "monday" || dayString == "понеділок"{
            dayNumber = 1
        } else if dayString == "tuesday" || dayString == "вівторок"{
            dayNumber = 2
        } else if dayString == "wednesday" || dayString == "середа"{
            dayNumber = 3
        } else if dayString == "thursday" || dayString == "четвер"{
            dayNumber = 4
        } else if dayString == "friday" || dayString == "п’ятниця"{
            dayNumber = 5
        } else if dayString == "saturday" || dayString == "суббота"{
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
    
    
    // MARK: - makeLessonsShedule
    /// Main function which fetch lessons from core data and remake `[Lesson]` to `[(key: DayName, value: [Lesson])]`
    /// - Note: call in `weekChanged()` and after getting data from `server()`
    /// - Remark: make shedule only for one week.
    func makeLessonsShedule() {
        let lessons = fetchingCoreData()
        getCurrentAndNextLesson(lessons: lessons)
        
        /// - todo: maybe delete temp
        var temp: [DayName : [Lesson]] = [:]
    
        var lessonsFirst: [Lesson] = []
        var lessonsSecond: [Lesson] = []
        
        for lesson in lessons {
            if Int(lesson.lessonWeek) == 1 {
                lessonsFirst.append(lesson)
            } else {
                lessonsSecond.append(lesson)
            }
        }
        
        let currentLessonWeek = currentWeek == 1 ? lessonsFirst : lessonsSecond
        
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
        
        temp = [DayName.mounday: lessonMounday,
                DayName.tuesday: lessonTuesday,
                DayName.wednesday: lessonWednesday,
                DayName.thursday: lessonThursday,
                DayName.friday: lessonFriday,
                DayName.saturday: lessonSaturday]
        
        let sorted = temp.sorted{$0.key < $1.key}

        self.lessonsForTableView = sorted

        if self.tableView != nil {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - fetchingCoreData
    /// Function which fetch lesson from core data
    func fetchingCoreData() -> [Lesson] {
        /// Core data request
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return []}

        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LessonData")
        
        var lessons: [Lesson] = []
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
                    let rate = lesson.value(forKey: "rate") as? String else { return []}
                    
                /// Add data to enum  (maybe can changed)
                let dayNameCoreData = DayName(rawValue: dayName) ?? DayName.mounday
                let lessonTypeCoreData = LessonType(rawValue: lessonType) ?? LessonType.empty
                
                /// Array of teacher which added to  variable `lesson` and then added to main variable `lessons`
                var teachers: [Teacher] = []
                var rooms: [Room] = []

                
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
                
                
                if let roomData = lesson.value(forKey: "roomsRelationship") as? RoomsData {

                    guard let roomID = roomData.roomID,
                        let roomName = roomData.roomName,
                        let roomLatitude = roomData.roomLatitude,
                        let roomLongitude = roomData.roomLongitude else { return []}

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
        
        return lessons
    }
    
    
    // MARK: - server
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
            self.deleteAllFromCoreData()

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
            
            /// Fetching and updating `lessonsForTableView` and tableView
            self.makeLessonsShedule()
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
            print("Could not delete. \(error)")
        }
    }
    
    
    // MARK:- weekChanged
    /// Function that calls when the user tap on segment conrol to change current week
    @IBAction func weekChanged(_ sender: UISegmentedControl) {
        switch weekSwitch.selectedSegmentIndex {
            case 0:
                currentWeek = 1
                makeLessonsShedule()
                tableView.reloadData()
            case 1:
                currentWeek = 2
                makeLessonsShedule()
                tableView.reloadData()
            default:
                break
        }
    }
    
    
    // MARK: - getCurrentAndNextLesson
    /// Function that makes current lesson **orange** and next lesson **blue**
    /// - todo: make some with time and Date
    /// - todo: rewrite function :)
    func getCurrentAndNextLesson(lessons: [Lesson]) {
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
        
        
        var lessonsFirst: [Lesson] = []
        var lessonsSecond: [Lesson] = []

        for lesson in lessons {
            if Int(lesson.lessonWeek) == 1 {
                lessonsFirst.append(lesson)
            } else {
                lessonsSecond.append(lesson)
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
    
    
    // MARK: - setEditing
    /// Calls when editing starts
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            self.tableView.setEditing(true, animated: true)
            self.tableView!.insertSections(IndexSet(integer: self.lessonsForTableView.count), with: .automatic)
        }
        else {
            self.tableView.setEditing(false, animated: true)
            self.tableView!.deleteSections(IndexSet(integer: self.lessonsForTableView.count), with: .automatic)
        }
    }
    
    
}


// MARK: - Table View Settings
extension SheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - numberOfSections
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isEditing == true {
            return 7
        } else {
            return 6
        }
    }
    

    // MARK: - titleForHeaderInSection
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {


        var array: [String] = [DayName.mounday.rawValue,
                               DayName.tuesday.rawValue,
                               DayName.wednesday.rawValue,
                               DayName.thursday.rawValue,
                               DayName.friday.rawValue,
                               DayName.saturday.rawValue]
        
        if self.isEditing != true {
            return array[section]
        } else {
            array.append("Новий предмет")
            return array[section]
        }
                
    }
    
    
    // MARK: - numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isEditing == true && section == self.lessonsForTableView.count {
            return 1
        }
        else {
            return self.lessonsForTableView[section].value.count
        }
    }
    
    
    // MARK: - prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailViewController" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let destination = segue.destination as? SheduleDetailViewController {
                    // Crash if tap on Add lesson
                    if indexPath.section != lessonsForTableView.count {
                        destination.lesson = lessonsForTableView[indexPath.section].value[indexPath.row]
                    }
                }
            }
        }
    }
    
    
    // MARK: - heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    
    // MARK: - didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard (storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? SheduleDetailViewController) != nil else { return }
        if indexPath.section != lessonsForTableView.count {
            performSegue(withIdentifier: "showDetailViewController", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    
    // MARK: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == self.lessonsForTableView.count && self.isEditing == true {
            // var cell: AddCell? = tableView.dequeueReusableCell(withIdentifier: "AddCell") as? AddCell
            let cell = UITableViewCell(style: .default, reuseIdentifier: "addCell")

            cell.textLabel?.text = "Добавить предмет"
            
            return cell
        }
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LessonTableViewCell", for: indexPath) as? LessonTableViewCell else {return UITableViewCell()}
        
        let lessonsForSomeDay = lessonsForTableView[indexPath.section].value
        
        
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
    
    
    // MARK: - commit editingStyle forRowAt
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let lesson = self.lessonsForTableView[indexPath.section].value[indexPath.row]

            

            
            var lessons: [Lesson] = []
            
            lessons = fetchingCoreData()
            
            for i in 0..<lessons.count - 1 {
                let lessonAll = lessons[i]
                if lessonAll.lessonID == lesson.lessonID {
                    lessons.remove(at: i)
                    break
                }
            }
            self.lessonsForTableView[indexPath.section].value.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            updateCoreData(datum: lessons)
        } else if editingStyle == .insert {
            presentAddLesson()
        }
    }
     
    
    // MARK: - moveRowAt sourceIndexPath to destinationIndexPath |
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let _ = (sourceIndexPath.row < self.lessonsForTableView[sourceIndexPath.section].value.count && destinationIndexPath.row < self.lessonsForTableView[sourceIndexPath.section].value.count)
        if true
        {
            var lessons: [Lesson] = []
            
            lessons = fetchingCoreData()
            
            var dayName = DayName.mounday
            
            switch destinationIndexPath.section {
                case 0:
                    dayName = DayName.mounday
                case 1:
                    dayName = DayName.tuesday
                case 2:
                    dayName = DayName.wednesday
                case 3:
                    dayName = DayName.thursday
                case 4:
                    dayName = DayName.friday
                case 5:
                    dayName = DayName.saturday
                
                default:
                    break
            }
            
            var lessonNumber = ""
            if destinationIndexPath.row == 0 {
               lessonNumber = "1"
            } else if destinationIndexPath.section == sourceIndexPath.section &&
                      destinationIndexPath.row > sourceIndexPath.row {
                lessonNumber = String(self.lessonsForTableView[destinationIndexPath.section].value[destinationIndexPath.row - 1].lessonNumber)
                
                var lessonNumberInt: Int = Int(lessonNumber) ?? 0
                lessonNumberInt += 2
                lessonNumber = String(lessonNumberInt)
                
            } else {
                lessonNumber = String(self.lessonsForTableView[destinationIndexPath.section].value[destinationIndexPath.row - 1].lessonNumber)
                
                var lessonNumberInt: Int = Int(lessonNumber) ?? 0
                lessonNumberInt += 1
                lessonNumber = String(lessonNumberInt)
                
            }
                         
            var timeStart = "00:00:00"
            var timeEnd = "00:00:00"
            
            switch lessonNumber {
                case "1":
                    timeStart = "08:30:00"
                    timeEnd = "10:05:00"
                case "2":
                    timeStart = "10:25:00"
                    timeEnd = "12:00:00"
                case "3":
                    timeStart = "12:20:00"
                    timeEnd = "13:55:00"
                case "4":
                    timeStart = "14:15:00"
                    timeEnd = "15:50:00"
                case "5":
                    timeStart = "16:10:00"
                    timeEnd = "17:45:00"
                default:
                    timeStart = "00:00:00"
                    timeEnd = "00:00:00"
            }
            
            var dayNumber = 0
            switch self.lessonsForTableView[destinationIndexPath.section].key {
                case .mounday:
                    dayNumber = 1
                case .tuesday:
                    dayNumber = 2
                case .wednesday:
                    dayNumber = 3
                case .thursday:
                    dayNumber = 4
                case .friday:
                    dayNumber = 5
                case .saturday:
                    dayNumber = 6
            }

            
            let lesson: Lesson = self.lessonsForTableView[sourceIndexPath.section].value[sourceIndexPath.row]
            
            let newLesson = Lesson(lessonID: lesson.lessonID,
                               groupID: lesson.groupID,
                               dayNumber: String(dayNumber),
                               dayName: dayName,
                               lessonName: lesson.lessonName,
                               lessonFullName: lesson.lessonFullName,
                               lessonNumber: String(lessonNumber),
                               lessonRoom: lesson.lessonRoom,
                               lessonType: lesson.lessonType,
                               teacherName: lesson.teacherName,
                               lessonWeek: lesson.lessonWeek,
                               timeStart: timeStart,
                               timeEnd: timeEnd,
                               rate: lesson.rate,
                               teachers: lesson.teachers,
                               rooms: lesson.rooms)

            self.lessonsForTableView[sourceIndexPath.section].value.remove(at: sourceIndexPath.row)
            
            self.lessonsForTableView[destinationIndexPath.section].value.insert(newLesson, at: destinationIndexPath.row)

            for i in 0..<lessons.count - 1 {
                let lessonAll = lessons[i]
                if lessonAll.lessonID == lesson.lessonID {
                    lessons.remove(at: i)
                    break
                }
            }
            
            lessons.append(newLesson)
            
            updateCoreData(datum: lessons)
            self.tableView.reloadData()

        }
    }
    
    
    // MARK: - canMoveRowAt
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == self.lessonsForTableView.count {
            return false
        }
        else {
            return true
        }
    }
    
    
    // MARK: - editingStyleForRowAt
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section == self.lessonsForTableView.count {
            return .insert
        }
        else {
            return .delete
        }
    }
    
    
    // MARK: - targetIndexPathForMoveFromRowAt sourceIndexPath toProposedIndexPath
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section >= self.lessonsForTableView.count {
            return sourceIndexPath
        }
        else {
            return proposedDestinationIndexPath
        }
    }
    
}
