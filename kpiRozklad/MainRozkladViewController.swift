//
//  MainRozkladViewController.swift
//  kpiRozklad
//
//  Created by Denis on 9/24/19.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

class MainRozkladViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let reuseID = "reuseID"
    var lessonsDays: [String] = []
    var lessonsName: [String] = []
    var lessons: [Datum] = []
    var lessonsFirst: [Datum] = []
    var lessonsSecond: [Datum] = []
    
    var week = 0
    var currentWeek = 1
    var weekOfYear = 0
    
    let date = Date()
    let formatter1 = DateFormatter()
    let formatter2 = DateFormatter()

    var time = ""
    var day = ""
    
    var isCurrent: Bool = false

    
    @IBOutlet weak var weekSwitch: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LessonTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "LessonTableViewCell")
        

        formatter1.dateFormat = "EEEE"
        formatter2.dateFormat = "HH:mm"

        day = formatter1.string(from: date)
        time = formatter2.string(from: date)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear, .month, .day, .weekday], from: date)
        weekOfYear = components.weekOfYear ?? 0
        
        
        print("weekOfYear", weekOfYear)
        print("day", day)
        print("time", time)

        
        server()
        
    }
    
    
    // MARK: - Get data from server

    func server() {
        let url = URL(string: "https://api.rozklad.org.ua/v2/groups/5489/lessons")!
        print(url)
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()

            do {
                guard let sereverFULLDATA = try? decoder.decode(Welcome.self, from: data) else { return }
                let datum = sereverFULLDATA.data
                self.lessons = datum
                
                self.sortLessons(datums: datum)
                
                if self.weekOfYear % 2 == 0 {
                    DispatchQueue.main.async {
                        self.currentWeek = 1

                        self.weekSwitch.selectedSegmentIndex = 0
                        self.tableView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.currentWeek = 2
                        self.weekSwitch.selectedSegmentIndex = 1
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        task.resume()
        
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
    
    func sortLessons(datums: [Datum]) {
        lessonsFirst = []
        lessonsSecond = []
        
        for datum in datums {
            if Int(datum.lessonWeek) == 1 {
                lessonsFirst.append(datum)
            } else {
                lessonsSecond.append(datum)
            }
        }
        
    }
    
   
        



}

// MARK: - Table View Settings
extension MainRozkladViewController: UITableViewDelegate, UITableViewDataSource {
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

        if currentWeek == 0 {
            var countMounday = 0
            var countTuesday = 0
            var countWednesday = 0
            var countThursday = 0
            var countFriday = 0
            
            for datu in lessonsFirst {
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
        } else {
            var countMounday = 0
            var countTuesday = 0
            var countWednesday = 0
            var countThursday = 0
            var countFriday = 0
            
            for datu in lessonsSecond {
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseID)
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LessonTableViewCell", for: indexPath) as? LessonTableViewCell
        else {return UITableViewCell()}
        
        print(lessonsFirst)
        print(indexPath.section)
        
        var lessonForSomeDay: [Datum] = []
        

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
        
        let timeStartString = lessonForSomeDay[indexPath.row].timeStart
//        let index1 = timeStartString.index(timeStartString.endIndex, offsetBy: -3)
//        let SubstringTimeStart = timeStartString.substring(to: index4)
        let substringTimeStart = String(timeStartString[..<5])
        
        let timeEndString = lessonForSomeDay[indexPath.row].timeEnd
        let substringTimeEnd = String(timeEndString[..<5])
        
        
        
        let timeStart = formatter2.date(from:substringTimeStart)!
        let timeCurrent = formatter2.date(from: time)!
        let timeEnd = formatter2.date(from:substringTimeEnd)!

        var dayNumber = 0
        if day == "Monday" {
            dayNumber = 1
        } else if day == "Tuesday" {
            dayNumber = 2
        } else if day == "Wednesday" {
            dayNumber = 3
        } else if day == "Thursday" {
            dayNumber = 4
        } else if day == "Friday" {
            dayNumber = 5
        } else if day == "Saturday" {
            dayNumber = 6
        }
        
        if  isCurrent == true {
                cell.backgroundColor = .green
                isCurrent = false
        }
        

        if  (timeStart < timeCurrent) &&
            (timeCurrent < timeEnd) &&
            (dayNumber == Int(lessonForSomeDay[indexPath.row].dayNumber)) &&
            (currentWeek == Int(lessonForSomeDay[indexPath.row].lessonWeek) ?? 0) {
                isCurrent = true
                cell.backgroundColor = .orange
        }
        print("currentWeek", currentWeek)
        print("lessonWeek", Int(lessonForSomeDay[indexPath.row].lessonWeek) ?? 0)
        
        // MARK: - next lesson
        
//        var nextTimeStartString: String = ""
//
//        let sec = indexPath.section
//        if lessonForSomeDay.count != indexPath.row {
//            nextTimeStartString = lessonForSomeDay[indexPath.row + 1].timeStart
//
//        } else {
//            nextTimeStartString = lessons[]
//        }
//        let index3 = nextTimeStartString.index(nextTimeStartString.endIndex, offsetBy: -3)
//        let nextSubstringTimeStart = nextTimeStartString.substring(to: index3)

//        let nextTimeEndString = lessonForSomeDay[indexPath.row + 1].timeEnd
//        let index4 = nextTimeEndString.index(nextTimeEndString.endIndex, offsetBy: -3)
//        let nextSubstringTimeEnd = nextTimeEndString.substring(to: index4)

//        let nextTimeStart = formatter2.date(from:nextSubstringTimeStart)!
//        let nextTimeEnd = formatter2.date(from:nextSubstringTimeEnd)!

        
        
        cell.startLabel.text = substringTimeStart
        cell.endLabel.text = substringTimeEnd
        
        return cell
    }
}
