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
/// 1. All in tableView works with `lessonsForTableView` variable, but Core Data saving `[Lesson]`
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
    let colour1 = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)

    /// Week switcher (1 and 2 week)
    @IBOutlet weak var weekSwitch: UISegmentedControl!
    
    /// ActivityIndicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// Picker from popup which edit number of lesson (tap on lesson while editing)
    var lessonNuberFromPicker: Int = 1
    
    /// Index Path from popup which edit number of lesson (tap on lesson while editing)
    var indexPathFromPicker: IndexPath?
    
    /// Settings singleton
    var settings = Settings.shared
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// presenting `GroupChooserViewController` if `settings.groupName == ""`
        presentGroupChooser()
        
        /// Button `Edit` & title (group name)
        setupNavigation()

        /// Start animating and show activityIndicator
        setupAtivityIndicator()
        
        /// TableView delegate and dataSource
        setupTableView()
        
        /// Getting dayNumber and week of year from device Date()
        getDayNumAndWeekOfYear()
        
        if settings.groupName != "" {
            /// setUpCurrentWeek (choosing week)
            setUpCurrentWeek()
            
            /// Fetching Core Data and make variable for tableView
            makeLessonsShedule()
        }
        
    }
        
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        /// presenting `GroupChooserViewController` if `settings.groupName == ""`
        presentGroupChooser()
        
        /// Getting dayNumber and week of year from device Date()
        getDayNumAndWeekOfYear()
        
        /// Choosing new Curent and next lesson
        if settings.groupName != "" {
            makeLessonsShedule()
            
            scrollToCurrentOrNext()
        }
        
        /// If Core Data is empty, making request from server
        if lessonsCoreData.isEmpty || settings.isTryToRefreshShedule {
            /// Start animating and show activityIndicator
            setupAtivityIndicator()
            
            server()
            
            settings.isTryToRefreshShedule = false
        }
        
        /// Reloading tableView if need
        if settings.isTryToReloadTableView {
            DispatchQueue.main.async {
                self.makeLessonsShedule()
                
                self.tableView.reloadData()
                
                self.settings.isTryToReloadTableView = false
            }
        }
        
    }
    
    
    private func setupTableView() {
        tableView.register(UINib(nibName: LessonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: LessonTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
    private func setupAtivityIndicator() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        tableView.isHidden = true
        self.view.bringSubviewToFront(activityIndicator)
    }
    
    
    private func setupNavigation() {
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.navigationItem.title = settings.groupName.uppercased()
    }
    
    
    // MARK: - presentGroupChooser
    /// Func which present `GroupChooserViewController` (navigationGroupChooser)
    func presentGroupChooser() {
        if settings.groupName == "" {
            deleteAllFromCoreData()

            self.lessonsForTableView = [DayName.mounday: [],
                                        .tuesday: [],
                                        .wednesday: [],
                                        .thursday: [],
                                        .friday: [],
                                        .saturday: []].sorted{$0.key < $1.key}
            tableView.reloadData()
            

            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let navigationGroupChooser : UINavigationController = mainStoryboard.instantiateViewController(withIdentifier: "navigationGroupChooser") as! UINavigationController
            
            navigationGroupChooser.isModalInPresentation = true
            self.present(navigationGroupChooser, animated: true, completion: {
                self.setupAtivityIndicator()
            })
            
            
            
        }
    }
    
    
    func scrollToCurrentOrNext() {
        var indexPathToScroll = IndexPath(row: 0, section: 0)

        k: for section in 0..<self.lessonsForTableView.count {
            let day = lessonsForTableView[section]
            for row in 0..<day.value.count {
                let lesson = day.value[row]
                if lesson.lessonID == currentLessonId {
                    print(currentLessonId)
                    print(section, row)
                    indexPathToScroll = IndexPath(row: row, section: section)
                    break k
                } else if lesson.lessonID == nextLessonId {
                    indexPathToScroll = IndexPath(row: row, section: section)
                    break k

                }
            }
        }
        

        /// (self.tableView != nil)  because if when we push information from another VC tableView can be not exist
        
        if self.tableView != nil {
            DispatchQueue.main.async {
//                self.tableView.isHidden = false
    //            indexPathToScroll = IndexPath(row: 3, section: 4)
                self.tableView.reloadData()
//                guard let some = self.lessonsForTableView.count else { return }
                if self.lessonsForTableView[indexPathToScroll.section].value.count > indexPathToScroll.row {
                    self.tableView.scrollToRow(at: indexPathToScroll, at: .top, animated: true)

                }
    //            print(self.tableView.cellForRow(at: indexPathToScroll)?.textLabel?.text)
            }
            

        }
    }
    
    
    // MARK: - presentAddLesson
    /// Func which present `AddLessonViewController`
    func presentAddLesson() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let addLesson : AddLessonViewController = mainStoryboard.instantiateViewController(withIdentifier: AddLessonViewController.identifier) as! AddLessonViewController
        
        addLesson.lessons = self.fetchingCoreData()
        addLesson.currentWeek = self.currentWeek
        
        self.present(addLesson, animated: true, completion: nil)
    }
    
    
    // MARK: - getDayNumAndWeekOfYear
    /// Getting dayNumber and week of year from device Date()
    func getDayNumAndWeekOfYear() {
        /// Current date from device
        let date = Date()
        
        /// Calendar
        let calendar = Calendar.current
        
        /// "HH:mm"  formatter (hours and minutes)
        let formatter2 = DateFormatter()

        formatter2.dateFormat = "HH:mm"
        
        /// time is now
        timeIsNowString = formatter2.string(from: date)
        
        /// Get number of week (in year) and weekday
        let components = calendar.dateComponents([.weekOfYear, .month, .day, .weekday], from: date)

        dayNumberFromCurrentDate = (components.weekday ?? 0) - 1
        weekOfYear = components.weekOfYear ?? 0

        /// In USA calendar week start on Sunday but in my shedule it start from mounday
        /// and if today is Sunday, in USA we start new week but for me its wrong and we take away one week and set dayNumber == 7
        if dayNumberFromCurrentDate == 0 {
            weekOfYear -= 1
            dayNumberFromCurrentDate = 7
        }

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
        /// fetching Core Data
        let lessons = fetchingCoreData()
        
        /// ID of Current and Next
        getCurrentAndNextLesson(lessons: lessons)
            
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
        
//        var indexPathToScroll = IndexPath()
        
        /// Choosing lesson from currnetWeek
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
        
//        k: for section in 0..<lessonsForTableView.count {
//            let day = lessonsForTableView[section]
//            for row in 0..<day.value.count {
//                let lesson = day.value[row]
//                if lesson.lessonID == currentLessonId {
//                    print(currentLessonId)
//                    indexPathToScroll = IndexPath(row: row, section: section)
//                    break k
//                } else if lesson.lessonID == nextLessonId {
//                    indexPathToScroll = IndexPath(row: row, section: section)
//                }
//            }
//        }
        

        /// (self.tableView != nil)  because if when we push information from another VC tableView can be not exist
        if self.tableView != nil {
            self.tableView.reloadData()
//            print(indexPathToScroll)
////            indexPathToScroll = IndexPath(row: 3, section: 4)
//            self.tableView.scrollToRow(at: indexPathToScroll, at: .top, animated: true)
            

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
        
        /// Getting all data from Core Data to [Lesson] struct
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
        
        /// (self.activityIndicator != nil)  because if when we push information from another VC tableView can be not exist
        if self.activityIndicator != nil {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
        
        /// (self.tableView != nil)  because if when we push information from another VC tableView can be not exist
        if self.tableView != nil {
            self.tableView.isHidden = false
        }
        
        return lessons
    }
    
    
    // MARK: - server
    /// Functon which getting data from server
    /// - note: This fuction call `updateCoreData()`
    func server() {
        guard let url = URL(string: "https://api.rozklad.org.ua/v2/groups/\(settings.groupID)/lessons") else { return }
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
    /// - Parameter datum: array of  [Lesson] whitch received from server
    func updateCoreData(datum:  [Lesson]) {
        DispatchQueue.main.async {
            /// Delete all
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
    func getCurrentAndNextLesson(lessons: [Lesson]) {
        nextLessonId = String()
        currentLessonId = String()
        
        for lesson in lessons {
            
            let timeStart = String(lesson.timeStart[..<5])
            let timeEnd = String(lesson.timeEnd[..<5])
                        
            if  (timeStart <= timeIsNowString) && (timeIsNowString < timeEnd) &&
                (dayNumberFromCurrentDate == Int(lesson.dayNumber)) && (currentWeekFromTodayDate == Int(lesson.lessonWeek) ?? 0) {
                currentLessonId = lesson.lessonID
            }
            
            if (timeStart > timeIsNowString) && (dayNumberFromCurrentDate == Int(lesson.dayNumber) ?? 0) && (currentWeekFromTodayDate == Int(lesson.lessonWeek) ?? 0) {
                nextLessonId = lesson.lessonID
                return
            } else if (dayNumberFromCurrentDate < Int(lesson.dayNumber) ?? 0) && (currentWeekFromTodayDate == Int(lesson.lessonWeek) ?? 0){
                nextLessonId = lesson.lessonID
                return
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
                return
            } else if nextLessonId == "" && currentWeekFromTodayDate == 1 {
                nextLessonId = lessonsSecond[0].lessonID
                return
            }
        }
        
        if lessonsFirst.count == 0 && lessonsSecond.count != 0 {
            nextLessonId = lessonsSecond[0].lessonID
            return
        } else if lessonsFirst.count != 0 && lessonsSecond.count == 0 {
            nextLessonId = lessonsFirst[0].lessonID
            return
        }
        
    }
    
    
    // MARK: - setEditing
    /// Calls when editing starts
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            self.tableView.setEditing(true, animated: true)
            self.tableView.insertSections(IndexSet(integer: self.lessonsForTableView.count), with: .automatic)
        }
        else {
            self.tableView.setEditing(false, animated: true)
            self.tableView.deleteSections(IndexSet(integer: self.lessonsForTableView.count), with: .automatic)
        }
    }
    
    
    // MARK: - getTimeFromLessonNumber
    /// Function which make lesson timeStart and timeEnd
    func getTimeFromLessonNumber(lessonNumber: String) -> (String, String) {
        var timeStart = ""
        var timeEnd = ""

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
        case "6":
            timeStart = "18:05:00"
            timeEnd = "19:40:00"
        default:
            timeStart = "00:00:00"
            timeEnd = "00:00:00"
        }
        
        return (timeStart, timeEnd)
    }
    
    
    // MARK: - editLessonNumber
    /// Function calls when user vant to edit lesson number
    /// - note: Next lesson automatically adjust
    /// - Parameter indexPath: (indexPathFromPicker) Index Path from popup which edit number of lesson (tap on lesson while editing)
    func editLessonNumber(indexPath: IndexPath) {
        var lessons = fetchingCoreData()
        let lesson = self.lessonsForTableView[indexPath.section].value[indexPath.row]
        
        /// timeStart && timeEnd
        let times = getTimeFromLessonNumber(lessonNumber: String(lessonNuberFromPicker))
        let timeStart = times.0
        let timeEnd = times.1

        let newLesson = Lesson(lessonID: lesson.lessonID,
                           groupID: lesson.groupID,
                           dayNumber: lesson.dayNumber,
                           dayName: lesson.dayName,
                           lessonName: lesson.lessonName,
                           lessonFullName: lesson.lessonFullName,
                           lessonNumber: String(lessonNuberFromPicker),
                           lessonRoom: lesson.lessonRoom,
                           lessonType: lesson.lessonType,
                           teacherName: lesson.teacherName,
                           lessonWeek: lesson.lessonWeek,
                           timeStart: timeStart,
                           timeEnd: timeEnd,
                           rate: lesson.rate,
                           teachers: lesson.teachers,
                           rooms: lesson.rooms)

        /// Deleting old
        self.lessonsForTableView[indexPath.section].value.remove(at: indexPath.row)

        /// Inserting new
        self.lessonsForTableView[indexPath.section].value.insert(newLesson, at: indexPath.row)

        /// deleting from `lessons`  which will be used for further updates in `updateCoreData(datum: lessons)`
        for i in 0..<lessons.count {
            let lessonAll = lessons[i]
            if lessonAll.lessonID == lesson.lessonID {
                lessons.remove(at: i)
                break
            }
        }

        /// Appending new to `lessons`
        lessons.append(newLesson)
        
        /// Lessons  in which time will change
        var lessonsToEdit: [Lesson] = []
        
        /// Getting lessons from `.section` (day)
        let lessonForSection = self.lessonsForTableView[indexPath.section].value
        
        /// Creating iterator
        var iterator = lessonForSection.makeIterator()
        
        /// It is added if the next lesson will change
        var i = 0
        
        /// iterating
        while let nLesson = iterator.next() {
            if Int(nLesson.lessonNumber) ?? 0 + i >= lessonNuberFromPicker && nLesson.lessonID != newLesson.lessonID {
                i += 1
                lessonsToEdit.append(nLesson)
            }
        }
        
        /// Modified lessons with a shifted schedule are created and old ones are deleted
        for lesson in lessonsToEdit {
            
            var lessonNumberIntEdited: Int = Int(lesson.lessonNumber) ?? 0
            lessonNumberIntEdited += 1
            let lessonNumberEdited = String(lessonNumberIntEdited)
            
            let timesEdited = getTimeFromLessonNumber(lessonNumber: lessonNumberEdited)
            let timeStartEdited = timesEdited.0
            let timeEndEdited = timesEdited.1
            
            let editedLesson = Lesson( lessonID: lesson.lessonID,
                                       groupID: lesson.groupID,
                                       dayNumber: lesson.dayNumber,
                                       dayName: lesson.dayName,
                                       lessonName: lesson.lessonName,
                                       lessonFullName: lesson.lessonFullName,
                                       lessonNumber: lessonNumberEdited,
                                       lessonRoom: lesson.lessonRoom,
                                       lessonType: lesson.lessonType,
                                       teacherName: lesson.teacherName,
                                       lessonWeek: lesson.lessonWeek,
                                       timeStart: timeStartEdited,
                                       timeEnd: timeEndEdited,
                                       rate: lesson.rate,
                                       teachers: lesson.teachers,
                                       rooms: lesson.rooms)
            
            lessons.removeAll { lesson -> Bool in
                return lesson.lessonID == editedLesson.lessonID
            }
            lessons.append(editedLesson)

        }
        
        lessons.sort { (lesson1, lesson2) -> Bool in

            if lesson1.lessonWeek == lesson2.lessonWeek && lesson1.dayNumber == lesson2.dayNumber {
                 return lesson1.lessonNumber < lesson2.lessonNumber
            } else if lesson1.lessonWeek == lesson2.lessonWeek {
                return lesson1.dayNumber < lesson2.dayNumber
            } else {
                return lesson1.lessonWeek < lesson2.lessonWeek
            }
            
        }

        /// updateCoreData with edited variable `lessons`
        updateCoreData(datum: lessons)
        tableView.reloadData()
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
        
        self.isEditing ? array.append("Новий предмет") : nil
        return array[section]
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
        if indexPath.section == lessonsForTableView.count {
            presentAddLesson()
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        /// Presenting alert (popup) with pickerView
        if isEditing {
            let screenWidth = UIScreen.main.bounds.width

            let alertView = UIAlertController(
                               title: nil,
                               message: "\n\n\n\n\n\n",
                               preferredStyle: .actionSheet)

            let pickerView = UIPickerView(frame:
                               CGRect(x: 0, y: 0, width: screenWidth - 16, height: 140))
            
            pickerView.dataSource = self
            pickerView.delegate = self

            alertView.view.addSubview(pickerView)
            
            alertView.addAction(UIAlertAction(title: "Змінити", style: .default, handler: { (_) in
                self.indexPathFromPicker = indexPath
                self.editLessonNumber(indexPath: self.indexPathFromPicker ?? IndexPath(row: 0, section: 0))
            }))
            
            
            alertView.addAction(UIAlertAction(title: "Назад", style: .cancel, handler: { (_) in
                print("User click Dismiss button")
            }))

            present(alertView, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)

        } else {
            
            /// Seque to `SheduleDetailViewController`
            guard (storyboard?.instantiateViewController(withIdentifier: SheduleDetailViewController.identifier) as? SheduleDetailViewController) != nil else { return }
            
            if indexPath.section != lessonsForTableView.count {
                performSegue(withIdentifier: "showDetailViewController", sender: self)
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
        
    
    // MARK: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /// Creating cell for adding new lessson
        if indexPath.section == self.lessonsForTableView.count && self.isEditing == true {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "addCell")

            cell.textLabel?.text = "Добавить предмет"
            
            return cell
        }
        
        /// Creating main cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LessonTableViewCell.identifier, for: indexPath) as? LessonTableViewCell else { return UITableViewCell() }
        
        let lessonsForSomeDay = lessonsForTableView[indexPath.section].value
        
        cell.lessonLabel.text = lessonsForSomeDay[indexPath.row].lessonName
        cell.teacherLabel.text = lessonsForSomeDay[indexPath.row].teacherName
        
        if lessonsForSomeDay[indexPath.row].teacherName == "" {
            cell.teacherLabel.text = " "
        }

        if currentLessonId == lessonsForSomeDay[indexPath.row].lessonID {
            cell.backgroundColor = .orange
        }
        
        if nextLessonId == lessonsForSomeDay[indexPath.row].lessonID {
            cell.backgroundColor = colour1
        }
        
        let timeStart = String(lessonsForSomeDay[indexPath.row].timeStart[..<5])
        
        let timeEnd = String(lessonsForSomeDay[indexPath.row].timeEnd[..<5])
        
        cell.startLabel.text = timeStart
        cell.endLabel.text = timeEnd
        cell.roomLabel.text = lessonsForSomeDay[indexPath.row].lessonType.rawValue + " " + lessonsForSomeDay[indexPath.row].lessonRoom
        

        return cell
    }
    
    
    // MARK: - commit editingStyle forRowAt
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            /// Lesson to delete
            let lesson = self.lessonsForTableView[indexPath.section].value[indexPath.row]
            
            var lessons = fetchingCoreData()
            
            /// deleting from `lessons`  which will be used for further updates in `updateCoreData(datum: lessons)`
            for i in 0..<lessons.count {
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
     
    
    // MARK: - moveRowAt sourceIndexPath to destinationIndexPath
    /// - todo: try to use iterator for `lessonsToEdit`
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let _ = (sourceIndexPath.row < self.lessonsForTableView[sourceIndexPath.section].value.count && destinationIndexPath.row < self.lessonsForTableView[sourceIndexPath.section].value.count)
        if (sourceIndexPath.row < self.lessonsForTableView[sourceIndexPath.section].value.count && destinationIndexPath.row < self.lessonsForTableView[sourceIndexPath.section].value.count)
        {
            /// getting all lessons (this variable will refresh coreData)
            var lessons: [Lesson] = fetchingCoreData()
            
            /// lesson which we moved
            let lesson: Lesson = self.lessonsForTableView[sourceIndexPath.section].value[sourceIndexPath.row]

            
            /// dayName && dayNumber
            var dayName: DayName
            var dayNumber = 0
            
            switch self.lessonsForTableView[destinationIndexPath.section].key {
            case .mounday:
                dayName = .mounday
                dayNumber = 1
            case .tuesday:
                dayName = .tuesday
                dayNumber = 2
            case .wednesday:
                dayName = .wednesday
                dayNumber = 3
            case .thursday:
                dayName = .thursday
                dayNumber = 4
            case .friday:
                dayName = .friday
                dayNumber = 5
            case .saturday:
                dayName = .saturday
                dayNumber = 6
            }
            
            /// lessonNumber
            var lessonNumber = ""
            if destinationIndexPath.row == 0 {
               lessonNumber = "1"
            } else if destinationIndexPath.section == sourceIndexPath.section &&
                      destinationIndexPath.row > sourceIndexPath.row {
                lessonNumber = String(self.lessonsForTableView[destinationIndexPath.section].value[destinationIndexPath.row].lessonNumber)
                
                var lessonNumberInt: Int = Int(lessonNumber) ?? 0
                lessonNumberInt += 1
                lessonNumber = String(lessonNumberInt)
                
            } else {
                lessonNumber = String(self.lessonsForTableView[destinationIndexPath.section].value[destinationIndexPath.row - 1].lessonNumber)
                
                var lessonNumberInt: Int = Int(lessonNumber) ?? 0
                lessonNumberInt += 1
                lessonNumber = String(lessonNumberInt)
            }
             
            /// timeStart && timeEnd
            let times = getTimeFromLessonNumber(lessonNumber: lessonNumber)
            let timeStart = times.0
            let timeEnd = times.1

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
            print(newLesson)

            self.lessonsForTableView[sourceIndexPath.section].value.remove(at: sourceIndexPath.row)

            self.lessonsForTableView[destinationIndexPath.section].value.insert(newLesson, at: destinationIndexPath.row)

            for i in 0..<lessons.count {
                let lessonAll = lessons[i]
                if lessonAll.lessonID == lesson.lessonID {
                    lessons.remove(at: i)
                    lessons.insert(newLesson, at: i)
                    break
                }
            }


            if newLesson.lessonNumber == lesson.lessonNumber && newLesson.dayNumber == lesson.dayNumber {
                return
            }
            
            /// editing lessons
            var lessonsToEdit: [Lesson] = []
            
            var nextLesson: Lesson?
                        
//            let lessonForSection = self.lessonsForTableView[destinationIndexPath.section].value
//            var iterator = lessonForSection.makeIterator()
//            var i = 0
//            while let nLesson = iterator.next() {
//                if Int(nLesson.lessonNumber) ?? 0 + i > destinationIndexPath.row + 1 && nLesson.lessonID != newLesson.lessonID{
//                    i += 1
//                    lessonsToEdit.append(nLesson)
//                }
//            }
            
            
//             TODO:- USE ITERATOR
            if self.lessonsForTableView[destinationIndexPath.section].value.count > destinationIndexPath.row + 1 {
                nextLesson = self.lessonsForTableView[destinationIndexPath.section].value[destinationIndexPath.row + 1]
            }

            var k = 0
            var i = 2

            if let nextLessonG = nextLesson {
                var next = nextLessonG
                var nextLessonNumber = Int(next.lessonNumber) ?? 0
                let currentLessonNumber = Int(lessonNumber) ?? 0


                for _ in 0..<10 {
                    if currentLessonNumber + k >= nextLessonNumber {
                        k += 1
                        lessonsToEdit.append(next)
                        if self.lessonsForTableView[destinationIndexPath.section].value.count > destinationIndexPath.row + i {
                            next = self.lessonsForTableView[destinationIndexPath.section].value[destinationIndexPath.row + i]
                            nextLessonNumber = Int(next.lessonNumber) ?? 0
                        } else {
                            break
                        }
                        i += 1
                    }
                }
            }
            
            /// Modified lessons with a shifted schedule are created and old ones are deleted
            for lesson in lessonsToEdit {
                
                var lessonNumberIntEdited: Int = Int(lesson.lessonNumber) ?? 0
                lessonNumberIntEdited += 1
                let lessonNumberEdited = String(lessonNumberIntEdited)
                
                let timesEdited = getTimeFromLessonNumber(lessonNumber: lessonNumberEdited)
                let timeStartEdited = timesEdited.0
                let timeEndEdited = timesEdited.1
                
                let editedLesson = Lesson( lessonID: lesson.lessonID,
                                           groupID: lesson.groupID,
                                           dayNumber: lesson.dayNumber,
                                           dayName: lesson.dayName,
                                           lessonName: lesson.lessonName,
                                           lessonFullName: lesson.lessonFullName,
                                           lessonNumber: lessonNumberEdited,
                                           lessonRoom: lesson.lessonRoom,
                                           lessonType: lesson.lessonType,
                                           teacherName: lesson.teacherName,
                                           lessonWeek: lesson.lessonWeek,
                                           timeStart: timeStartEdited,
                                           timeEnd: timeEndEdited,
                                           rate: lesson.rate,
                                           teachers: lesson.teachers,
                                           rooms: lesson.rooms)
                
                lessons.removeAll { lesson -> Bool in
                    return lesson.lessonID == editedLesson.lessonID
                }

                lessons.append(editedLesson)
            }
            
            lessons.sort { (lesson1, lesson2) -> Bool in

                if lesson1.lessonWeek == lesson2.lessonWeek && lesson1.dayNumber == lesson2.dayNumber {
                     return lesson1.lessonNumber < lesson2.lessonNumber
                } else if lesson1.lessonWeek == lesson2.lessonWeek {
                    return lesson1.dayNumber < lesson2.dayNumber
                } else {
                    return lesson1.lessonWeek < lesson2.lessonWeek
                }
                
            }
            
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
        } else if isEditing {
            return .delete
        } else {
            return .none
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


// MARK: - Picker View Settings
extension SheduleViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    // MARK: - numberOfComponents
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    // MARK: - numberOfRowsInComponent
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 6
    }
    
    
    // MARK: - attributedTitleForRow
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let array = ["1 пара", "2 пара", "3 пара", "4 пара", "5 пара", "6 пара"]

        let attributedString = NSAttributedString(string: array[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])

        return attributedString
    }
    
    
    // MARK: - didSelectRow
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lessonNuberFromPicker = row + 1
    }
    
}
