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
        
    /**
        Сurrent week whlessonsCoreDataich is obtained from the date on the device
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
    let colour1 = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)

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
    
    @IBOutlet weak var tableViewTopConstaint: NSLayoutConstraint!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// presenting `GroupChooserViewController` if `settings.groupName == ""`
        presentGroupChooser()
        
        /// Button `Edit` & title (group name)
        setupNavigation()
        
        /// TableView delegate and dataSource
        setupTableView()

        /// Start animating and show activityIndicator
        setupAtivityIndicator()
        
        /// Getting dayNumber and week of year from device Date()
        setupDate()
        
        if settings.groupName != "" {
            /// setUpCurrentWeek (choosing week)
            setupCurrentWeek()
            
            /// Fetching Core Data and make variable for tableView
            makeLessonsShedule()
            
            /// scrollToCurrentOrNext()
            scrollToCurrentOrNext()
        }
        
    }
        
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        setupAtivityIndicator()

        /// presenting `GroupChooserViewController` if `settings.groupName == ""`
        presentGroupChooser()
        
        /// Getting dayNumber and week of year from device Date()
        setupDate()
        
        
        /// Choosing new Curent and next lesson
        if settings.groupName != "" {
            makeLessonsShedule()
        }
        
        if  lessonsForTableView[0].value.count == 0 &&
            lessonsForTableView[1].value.count == 0 &&
            lessonsForTableView[2].value.count == 0 &&
            lessonsForTableView[3].value.count == 0 &&
            lessonsForTableView[4].value.count == 0 {
            setupAtivityIndicator()
        }
        
        /// If Core Data is empty, making request from server
        if settings.isTryToRefreshShedule {
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
//        var insetsContentViewsToSafeArea: Bool = true
//        tableView.insetsContentViewsToSafeArea = false

    }
    
    
    private func setupDate() {
        let result = getTimeAndDayNumAndWeekOfYear()
        timeIsNowString = result.timeIsNowString
        dayNumberFromCurrentDate = result.dayNumberFromCurrentDate
        weekOfYear = result.weekOfYear
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
        self.navigationItem.largeTitleDisplayMode = .always
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationController?.navigationBar.isTranslucent = true

    }
    
    
    // MARK: - setupCurrentWeek
    /// Simple function to set up currnet week in viewDidLoad
    func setupCurrentWeek() {
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
            
            if #available(iOS 13.0, *) {
                navigationGroupChooser.isModalInPresentation = true
            } else {
                // Fallback on earlier versions
            }
            self.present(navigationGroupChooser, animated: true, completion: { self.setupAtivityIndicator() })
        }
    }
    
    
    // MARK: - presentAddLesson
    /// Func which present `AddLessonViewController`
    func presentAddLesson() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let addLesson : AddLessonViewController = mainStoryboard.instantiateViewController(withIdentifier: AddLessonViewController.identifier) as! AddLessonViewController
        
        addLesson.lessons = fetchingCoreData()
        addLesson.currentWeek = self.currentWeek
        
        self.present(addLesson, animated: true, completion: nil)
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
            self.tableView.reloadData()
            
            DispatchQueue.main.async {

                if self.lessonsForTableView[indexPathToScroll.section].value.count > indexPathToScroll.row {
                    self.tableView.scrollToRow(at: indexPathToScroll, at: .top, animated: true)
                }
            }
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
        if self.activityIndicator != nil {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
        
        /// (self.tableView != nil)  because if when we push information from another VC tableView can be not exist
        if self.tableView != nil {
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
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
                print(url)
                if let error = try? decoder.decode(Error.self, from: data) {
                    if error.message == "Lessons not found" {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: nil, message: "Розкладу для цієї групи не існує", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Змінити групу", style: .default, handler: { (_) in
                                self.settings.groupName = ""
                                self.presentGroupChooser()
                            }))
                            
                            self.present(alert, animated: true, completion: {
                                self.settings.isTryToRefreshShedule = true
                            })
                        }
                    }
                }
                
                
                guard let serverFULLDATA = try? decoder.decode(WelcomeLessons.self, from: data) else { return }
                print(serverFULLDATA)
                let datum = serverFULLDATA.data

                updateCoreData(vc: self, datum: datum)
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
                        
        self.isEditing ? array.append("Нова пара") : nil
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
                editLessonNumber(vc: self, indexPath: self.indexPathFromPicker ?? IndexPath(row: 0, section: 0))
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

            cell.textLabel?.text = "Додати пару"
            
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
            updateCoreData(vc: self, datum: lessons)
            
        } else if editingStyle == .insert {
            presentAddLesson()
        }
    }
     
    
    // MARK: - moveRowAt sourceIndexPath to destinationIndexPath
    /// - todo: try to use iterator for `lessonsToEdit`
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveRow(vc: self, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
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
