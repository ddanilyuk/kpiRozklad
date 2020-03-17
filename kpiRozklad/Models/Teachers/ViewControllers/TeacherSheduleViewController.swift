//
//  TeacherSheduleViewController.swift
//  kpiRozklad
//
//  Created by Denis on 12.10.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

/// Some about how it works
///
/// ## Important things ##
///
/// 1. All in tableView works with `lessonsForTableView` variable, but Core Data saving `[Lesson]`
/// 2. `makeLessonsShedule()` remake `[TeacherFull]` to `[(key: DayName, value: [TeacherFull])]`
/// 3. `server()` call `updateCoreData(datum:  [TeacherFull])` where datum is `[Lesson]` from API
/// 4. `fetchingCoreData() -> [TeacherFull]` return `[TeacherFull]` from Core Data
class TeacherSheduleViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    /// ReuseID for tableView
    let reuseID = "reuseID2"

    /// Variable with which updated from `server()` and used in `makeLessonsShedule()`
    var lessons: [Lesson] = []
    
    /// The **main** variable with which the table is updated
    var lessonsForTableView: [(key: DayName, value: [Lesson])] = []

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
    ///     Set  up in `getCurrentAndNextLesson(lessons: [TeacherFull])`
    var currentLessonId = String()
    
    /// Lesson ID of **next** Lesson
    ///- Remark:
    ///     Set  up in `getCurrentAndNextLesson(lessons: [TeacherFull])`
    var nextLessonId = String()
    
    /// Nav Bar
    @IBOutlet weak var navBar: UINavigationItem!
    
    /// Variable from seque
    var teacher: Teacher?
    
    /// ID for  `server()`
    var teacherID: String?
    
    /// Colour of next lesson
    let colour1 = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)

    /// Week switcher (1 and 2 week)
    @IBOutlet weak var weekSwitch: UISegmentedControl!
    
    /// ActivityIndicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var favouriteBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var favouriteButton: UIButton!
    
    var isFavourite: Bool = false
    
    let favourites = Favourites.shared
    
    var isFromFavourites: Bool = false
    
    var isFromTeachersVC: Bool = false
    
    var lessonsFromServer: [Lesson] = []

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        setupDate()
        
        /// setUpCurrentWeek (choosing week)
        setUpCurrentWeek()
        
        /// Set Up title
        let title = "Зараз \(self.currentWeekFromTodayDate) тиждень"
        self.navBar.title = title
        
        
        if teacher != nil {
            teacherID = teacher?.teacherID
        }
        
        /// Start animating and show activityIndicator
        activityIndicator.startAnimating()
        tableView.isHidden = true
        self.view.bringSubviewToFront(activityIndicator)
        
        /// Making request from server
        if isFromFavourites || isFromTeachersVC {
            lessons = lessonsFromServer
            
            DispatchQueue.main.async {
                /// Show tableView
                self.tableView.isHidden = false
                
                /// Hide Activity Indicator
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        } else {
            server()
        }
        
        makeTeachersLessonsShedule()
        
        checkIfGroupInFavourites()
    }
    
    
    func checkIfGroupInFavourites() {
        if let strongTeacher = teacher {
            if favourites.favouriteTeachersID.contains(Int(strongTeacher.teacherID) ?? 0) {
                if let image = UIImage(named: "icons8-christmas-star-90-filled") {
                    favouriteButton.setImage(image, for: .normal)
                    isFavourite = true
                }
            }
        }
    }
    
    
    private func setupDate() {
        let result = getTimeAndDayNumAndWeekOfYear()
        timeIsNowString = result.timeIsNowString
        dayNumberFromCurrentDate = result.dayNumberFromCurrentDate
        weekOfYear = result.weekOfYear
    }
    
    
    private func setupTableView() {
        /// TableView delegate and dataSource
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LessonTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "LessonTableViewCell")
    }
//    // MARK: - getDayNumAndWeekOfYear
//    /// Getting dayNumber and week of year from device Date()
//    func getDayNumAndWeekOfYear() {
//        /// Current date from device
//        let date = Date()
//
//        /// Calendar
//        let calendar = Calendar.current
//
//        /// "EEEE"  formatter (day)
//        let formatter1 = DateFormatter()
//
//        /// "HH:mm"  formatter (hours and minutes)
//        let formatter2 = DateFormatter()
//
//        formatter1.dateFormat = "EEEE"
//        formatter2.dateFormat = "HH:mm"
//
//        /// time is now
//        timeIsNowString = formatter2.string(from: date)
//
//        /// Get number of week (in year) and weekday
//        let components = calendar.dateComponents([.weekOfYear, .month, .day, .weekday], from: date)
//
//        dayNumberFromCurrentDate = (components.weekday ?? 0) - 1
//        weekOfYear = components.weekOfYear ?? 0
//
//        /// In USA calendar week start on Sunday but in my shedule it start from mounday
//        /// and if today is Sunday, in USA we start new week but for me its wrong and we take away one week and set dayNumber == 7
//        if dayNumberFromCurrentDate == 0 {
//            weekOfYear -= 1
//            dayNumberFromCurrentDate = 7
//        }
//    }
    
    
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
    /// Main function which remake `[TeacherFull]` to `[(key: DayName, value: [TeacherFull])]` from `server()`
    /// - Note: call in `weekChanged()` and after getting data from `server()`
    /// - Remark: make shedule only for one week.
    func makeTeachersLessonsShedule() {
        
        /// ID of Current and Next
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
        
        /// .sorting is soting from mounday to saturday (must be in normal order)
        self.lessonsForTableView = [DayName.mounday: lessonMounday,
                                    DayName.tuesday: lessonTuesday,
                                    DayName.wednesday: lessonWednesday,
                                    DayName.thursday: lessonThursday,
                                    DayName.friday: lessonFriday,
                                    DayName.saturday: lessonSaturday].sorted{$0.key < $1.key}
        /// (self.tableView != nil)  because if when we push information from another VC tableView can be not exist
        if self.tableView != nil {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - server
    func server() {
        guard var url = URL(string: "https://api.rozklad.org.ua/v2/teachers/") else { return }
        url.appendPathComponent(teacherID ?? "")
        url.appendPathComponent("/lessons")
        print(url)
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()

            do {
                if let error = try? decoder.decode(Error.self, from: data) {
                    if error.message == "Lessons not found" {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: nil, message: "Розкладу для цього викладача не існує", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Назад", style: .default, handler: { (_) in
                                self.navigationController?.popViewController(animated: true)
                            }))
                            
                            self.present(alert, animated: true, completion: {
                            })
                        }
                    }
                }
                
                
                guard let serverFULLDATA = try? decoder.decode(WelcomeLessons.self, from: data) else { return }
                let datum = serverFULLDATA.data
                self.lessons = datum
            }
            
            DispatchQueue.main.async {
                /// Making normal shedule + reloading tableVIew
                self.makeTeachersLessonsShedule()
                
                /// Show tableView
                self.tableView.isHidden = false
                
                /// Hide Activity Indicator
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
        
        task.resume()
        
    }
    
    
    // MARK:- weekChanged
    /// Function that calls when the user tap on segment conrol to change current week
    @IBAction func weekChanged(_ sender: UISegmentedControl) {
        switch weekSwitch.selectedSegmentIndex {
            case 0:
                currentWeek = 1
                makeTeachersLessonsShedule()
                tableView.reloadData()
            case 1:
                currentWeek = 2
                makeTeachersLessonsShedule()
                tableView.reloadData()
            default:
                break
        }
    }
    
    
    
    @IBAction func didPressFavourite(_ sender: UIButton) {
        guard let strongTeacher = teacher else { return }
        
        if isFavourite {
            if let image = UIImage(named: "icons8-christmas-star-75-add-1") {
                print(favourites.favouriteTeachersID)

                for i in 0..<favourites.favouriteTeachersID.count {
                    
                    if Int(strongTeacher.teacherID) ?? 0 == favourites.favouriteTeachersID[i] {
                        favouriteButton.setImage(image, for: .normal)
                        _ = favourites.favouriteTeachersNames.remove(at: i)
                        _ = favourites.favouriteTeachersID.remove(at: i)
                        isFavourite = false
                        return
                    }
                }
                
                print(favourites.favouriteTeachersNames)
                print(favourites.favouriteTeachersID)
            }
        } else {
            if let image = UIImage(named: "icons8-christmas-star-90-filled") {
                favouriteButton.setImage(image, for: .normal)
                favourites.favouriteTeachersNames.append(strongTeacher.teacherFullName)
                favourites.favouriteTeachersID.append(Int(strongTeacher.teacherID) ?? 0)

                isFavourite = true
                
                print(favourites.favouriteTeachersNames)
                print(favourites.favouriteTeachersID)
            }
        }
        
    }
    
    

}


// MARK: - Table View Settings
extension TeacherSheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - numberOfSections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }

    
    // MARK: - titleForHeaderInSection
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getArrayOfDayNames()[section].rawValue
    }
    
    
    // MARK: - numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lessonsForTableView[section].value.count
    }
    
    
    // MARK: - heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    
    // MARK: - didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lesson = lessonsForTableView[indexPath.section].value[indexPath.row]
        
        let groupsNames = getGroupsOfLessonString(lesson: lesson)
        
        let alert = UIAlertController(title: nil, message: "Групи: \(groupsNames)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Назад", style: .cancel, handler: { (_) in
            
        }))
        
        self.present(alert, animated: true, completion: {
        })
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let array: [String] = [DayName.mounday.rawValue,
                               DayName.tuesday.rawValue,
                               DayName.wednesday.rawValue,
                               DayName.thursday.rawValue,
                               DayName.friday.rawValue,
                               DayName.saturday.rawValue]
                
        returnedView.backgroundColor = sectionColour

        let label = UILabel(frame: CGRect(x: 16, y: 3, width: view.frame.size.width, height: 25))
        label.text = array[section]

        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        returnedView.addSubview(label)

        return returnedView
    }
    
    
    // MARK: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LessonTableViewCell", for: indexPath) as? LessonTableViewCell else {return UITableViewCell()}
        
        let lessonsForSomeDay = lessonsForTableView[indexPath.section].value

        cell.lessonLabel.text = lessonsForSomeDay[indexPath.row].lessonName
        cell.teacherLabel.text = lessonsForSomeDay[indexPath.row].teacherName
        
        if lessonsForSomeDay[indexPath.row].teacherName == "" {
            let nothing = " "
            cell.teacherLabel.text = nothing
        }
        
        let vc = SheduleViewController()
        
        if currentLessonId == lessonsForSomeDay[indexPath.row].lessonID {
            vc.setupCurrentLessonCell(cell: cell)
        }
        
        if nextLessonId == lessonsForSomeDay[indexPath.row].lessonID {
            vc.setupNextLessonCell(cell: cell)

//            cell.backgroundColor = colour1
        }
        
    
        let timeStartString = lessonsForSomeDay[indexPath.row].timeStart
        let substringTimeStart = String(timeStartString[..<5])
        
        let timeEndString = lessonsForSomeDay[indexPath.row].timeEnd
        let substringTimeEnd = String(timeEndString[..<5])
        
        cell.startLabel.text = substringTimeStart
        cell.endLabel.text = substringTimeEnd
        cell.roomLabel.text = lessonsForSomeDay[indexPath.row].lessonType.rawValue + " " + lessonsForSomeDay[indexPath.row].lessonRoom
        cell.timeLeftLabel.text = ""
        return cell
    }
}
