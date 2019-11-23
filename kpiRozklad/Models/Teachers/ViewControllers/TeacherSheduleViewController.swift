//
//  TeacherViewController.swift
//  kpiRozklad
//
//  Created by Denis on 12.10.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

class TeacherSheduleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let reuseID = "reuseID2"

    /// Variable with which updated from `server()` and used in `makeLessonsShedule()`
    var lessons: [TeacherFull] = []
    
    
    var lessonsForTableView: [(key: DayName, value: [TeacherFull])] = []

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

    var timeString = ""
    var timeDate = Date()
    var dayString = ""
    
    var currentLessonId = ""
    var nextLessonId = ""
    var nextLessonDate = Date()
    
    let colour1 = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
    let colour2 = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    var teacher: Teacher?
    var teacherID: String?
    
    @IBOutlet weak var weekSwitch: UISegmentedControl!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LessonTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "LessonTableViewCell")
        
        getDayNumAndWeekOfYear()
        setUpCurrentWeek()
                
        server()

        
        // guard let teacher = teacher else { return }
        if teacher != nil {
            teacherID = teacher?.teacherID
        }
        
        
        activityIndicator.startAnimating()
        tableView.isHidden = true
        self.view.bringSubviewToFront(activityIndicator)
        
    }
    
    
    // MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
          getCurrentAndNextLesson(lessons: lessons)
    }
    
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        let title = "Зараз \(self.currentWeekFromTodayDate) тиждень"
        self.navBar.title = title
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
    
    
    func makeLessonsShedule() {
        getCurrentAndNextLesson(lessons: lessons)
        
        /// - todo: maybe delete temp
        var temp: [DayName : [TeacherFull]] = [:]
    
        var lessonsFirst: [TeacherFull] = []
        var lessonsSecond: [TeacherFull] = []
        
        for lesson in lessons {
            if Int(lesson.lessonWeek) == 1 {
                lessonsFirst.append(lesson)
            } else {
                lessonsSecond.append(lesson)
            }
        }
        
        let currentLessonWeek = currentWeek == 1 ? lessonsFirst : lessonsSecond
        
        var lessonMounday: [TeacherFull] = []
        var lessonTuesday: [TeacherFull] = []
        var lessonWednesday: [TeacherFull] = []
        var lessonThursday: [TeacherFull] = []
        var lessonFriday: [TeacherFull] = []
        var lessonSaturday: [TeacherFull] = []
        
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
    
    
    // MARK: - server
    func server() {
        var url = URL(string: "https://api.rozklad.org.ua/v2/teachers/")!
        url.appendPathComponent(teacherID ?? "")
        url.appendPathComponent("/lessons")
        print(url)
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()

            do {
                guard let serverFULLDATA = try? decoder.decode(WelcomeTeachersFull.self, from: data) else { return }
                let datum = serverFULLDATA.data
                self.lessons = datum                
                
                
            }
            DispatchQueue.main.async {
                self.makeLessonsShedule()
                self.tableView.isHidden = false
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
        
        task.resume()
        
    }
    
    
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
    func getCurrentAndNextLesson(lessons: [TeacherFull]) {
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
        
        
        var lessonsFirst: [TeacherFull] = []
        var lessonsSecond: [TeacherFull] = []

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
    
}


// MARK: - Table View Settings
extension TeacherSheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }

    
    /// TitleForHeaderInSections
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let array: [String] = [DayName.mounday.rawValue,
                               DayName.tuesday.rawValue,
                               DayName.wednesday.rawValue,
                               DayName.thursday.rawValue,
                               DayName.friday.rawValue,
                               DayName.saturday.rawValue]
        
        return array[section]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lessonsForTableView[section].value.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
}
