//
//  MainRozkladViewController.swift
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

    var lessons: [Datum] = []
    var lessonsCoreData: [NSManagedObject] = []
    
    var lessonsFirst: [Datum] = []
    var lessonsSecond: [Datum] = []
    var lessonForSomeDay: [Datum] = []
    
    var lessonsFirstCoreData: [NSManagedObject] = []
    var lessonsSecondCoreData: [NSManagedObject] = []
    var lessonForSomeDayCoreData: [NSManagedObject] = []


    var isCoreData = true
    
    var currentWeekFromTodayDate = 1
    var currentWeek = 1
    var weekOfYear = 0
    var dayNumber = 0
    
    let date = Date()
    let calendar = Calendar.current
    let formatter1 = DateFormatter()
    let formatter2 = DateFormatter()

    var timeString = ""
    var timeDate = Date()
    var dayString = ""
    
    var currentLessonId = ""
    var nextLessonId = ""
    var nextLessonDate = Date()
    
    let colour1 = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
    let colour2 = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)

    
    @IBOutlet weak var weekSwitch: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LessonTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "LessonTableViewCell")
        
        getDayNumAndWeekOfYear()
        
        
        if self.weekOfYear % 2 == 0 {
            self.currentWeekFromTodayDate = 1
            DispatchQueue.main.async {
                self.weekSwitch.selectedSegmentIndex = 0
                self.currentWeek = 1
            }
        } else {
            self.currentWeekFromTodayDate = 2
            DispatchQueue.main.async {
                self.weekSwitch.selectedSegmentIndex = 1
                self.currentWeek = 2
            }
        }
        
        

        
        
        
        
        
        
//        let appDelegate = UIApplication.shared.delegate as? AppDelegate
//        self.appDelegate?.scheduleNotification(notificationType: notificationType)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getCurrentAndNextLesson()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {

        //1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext

        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Lesson")

        //3
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
                let dayNameCoreData = DayName(rawValue: dayName) ?? DayName(rawValue: "Понеділок")!
                let lessonTypeCoreData = LessonType(rawValue: lessonType) ?? LessonType(rawValue: "")!
                
                let lesson = Datum(lessonID: lessonID, groupID: groupID, dayNumber: dayNumber, dayName: dayNameCoreData, lessonName: lessonName, lessonFullName: lessonFullName, lessonNumber: lessonNumber, lessonRoom: lessonRoom, lessonType: lessonTypeCoreData, teacherName: teacherName, lessonWeek: lessonWeek, timeStart: timeStart, timeEnd: timeEnd, rate: rate, teachers: [], rooms: [])
                
                lessons.append(lesson)
            }
            
            
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        sortLessons()
        getCurrentAndNextLesson()
        tableView.reloadData()
        
        if lessonsCoreData.isEmpty {
            server()
        }
        

    }
    
    
    func getDayNumAndWeekOfYear() {
        formatter1.dateFormat = "EEEE"
        formatter2.dateFormat = "HH:mm"
        dayString = formatter1.string(from: date)
        timeString = formatter2.string(from: date)
        timeDate = formatter2.date(from: timeString) ?? Date()

        // Get today's number in week (from 1 to 7)
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
        // Get number of week (in year)
        let components = calendar.dateComponents([.weekOfYear, .month, .day, .weekday], from: date)
        weekOfYear = components.weekOfYear ?? 0
    }
    
    
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
    
    // MARK: - Get data from server

    func server() {
        let url = URL(string: "https://api.rozklad.org.ua/v2/groups/5489/lessons")!
        print(url)
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()

            do {
                guard let serverFULLDATA = try? decoder.decode(Welcome.self, from: data) else { return }
                let datum = serverFULLDATA.data

                self.updateCoreData(datum: datum)
            }
        }

        task.resume()
        
    }
    
    
    func updateCoreData(datum:  [Datum]) {
        // MARK:- Add core data
        
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

            // 1
            let managedContext = appDelegate.persistentContainer.viewContext

            for lesson in datum {
                // 2
                let entity = NSEntityDescription.entity(forEntityName: "Lesson", in: managedContext)!

                let lessonCoreData = NSManagedObject(entity: entity, insertInto: managedContext)

                // 3
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


                // 4
                do {
                    try managedContext.save()
                    self.lessonsCoreData.append(lessonCoreData)
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                self.sortLessons()
                self.tableView.reloadData()
            }
            
        }
    }
    
    
    func deleteAllFromCoreData() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Lesson")

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        // Configure Fetch Request
        fetchRequest.includesPropertyValues = false

        do {
            let managedContext = appDelegate.persistentContainer.viewContext

            let items = try managedContext.fetch(fetchRequest) as! [NSManagedObject]

            for item in items {
                managedContext.delete(item)
            }

            // Save Changes
            try managedContext.save()

        } catch {
            // Error Handling
        }

    }
    
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
                    lessonForSomeDay = []
                    if currentWeek == 1 {
                        for lesson in lessonsFirst {
                            if Int(lesson.dayNumber) == (indexPath.section + 1) {
                                lessonForSomeDay.append(lesson)
                            }
                        }
                    } else {
                        for lesson in lessonsSecond {
                            if Int(lesson.dayNumber) == (indexPath.section + 1) {
                                lessonForSomeDay.append(lesson)
                            }
                        }
                    }
                    destination.lesson = lessonForSomeDay[indexPath.row]
                    
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
        
        lessonForSomeDay = []
        
        if currentWeek == 1 {
            for lesson in lessonsFirst {
                if Int(lesson.dayNumber) == (indexPath.section + 1) {
                    lessonForSomeDay.append(lesson)
                }
            }
        } else {
            for lesson in lessonsSecond {
                if Int(lesson.dayNumber) == (indexPath.section + 1) {
                    lessonForSomeDay.append(lesson)
                }
            }
        }
        
        cell.lessonLabel.text = lessonForSomeDay[indexPath.row].lessonName
        cell.teacherLabel.text = lessonForSomeDay[indexPath.row].teacherName
        
        if lessonForSomeDay[indexPath.row].teacherName == "" {
            let nothing = " "
            cell.teacherLabel.text = nothing
        }

        
        if currentLessonId == lessonForSomeDay[indexPath.row].lessonID {
            cell.backgroundColor = .orange
        }
        
        if nextLessonId == lessonForSomeDay[indexPath.row].lessonID {
            cell.backgroundColor = colour1
        }
        
    
        
        let timeStartString = lessonForSomeDay[indexPath.row].timeStart
        let substringTimeStart = String(timeStartString[..<5])
        
        let timeEndString = lessonForSomeDay[indexPath.row].timeEnd
        let substringTimeEnd = String(timeEndString[..<5])
        
        cell.startLabel.text = substringTimeStart
        cell.endLabel.text = substringTimeEnd
        cell.roomLabel.text = lessonForSomeDay[indexPath.row].lessonType.rawValue + " " + lessonForSomeDay[indexPath.row].lessonRoom
        
        return cell
    }
}
