//
//  SheduleViewController.swift
//  kpiRozklad
//
//  Created by Denis on 9/24/19.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit
import CoreData
import PromiseKit


/**
 ## Important things ##
 
 1.  All in tableView works with `lessonsForTableView` variable, but Core Data saving `[Lesson]`
 2. `getLessonsFromServer()` receives data from the server and call `updateCoreData(vc: SheduleViewController, datum:  [Lesson])` where datum is `[Lesson]` from API
 3. `fetchingCoreData(vc: SheduleViewController) -> [Lesson]` return `[Lesson]` from Core Data
 4. `makeLessonsShedule()` remake `[Lesson]` to `[(key: DayName, value: [Lesson])]`
 */
class SheduleViewController: UIViewController {

    // MARK: - Variables
    /// Window
    var window: UIWindow?
    
    /// Main table view
    @IBOutlet weak var tableView: UITableView!
    
    /// Week switcher (1 and 2 week)
    @IBOutlet weak var weekSegmentControl: UISegmentedControl!
    
    /// Activity indicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// Favourite bar button item
    @IBOutlet weak var favouriteBarButtonItem: UIBarButtonItem!
    
    /// Bar button item with  segment control (which change week)
    @IBOutlet weak var segmentBatButtonItem: UIBarButtonItem!
    
    /// Favourite vutton
    @IBOutlet weak var favouriteButton: UIButton!
    
    /**
     The **main** variable by which the table view is updated
        - Remark: for default is empty
     */
    var lessonsForTableView: [(key: DayName, value: [Lesson])] = [DayName.mounday: [],
                                                                  .tuesday: [],
                                                                  .wednesday: [],
                                                                  .thursday: [],
                                                                  .friday: [],
                                                                  .saturday: []].sorted{$0.key < $1.key}
        
    /**
     Сurrent week which is obtained from the date on the device
     - Remark:
        Set  up in `setUpCurrentWeek()`
     */
    var currentWeekFromTodayDate = 1
    
    /**
     Current  week which user chosed
     - Remark:
        Set up in `setUpCurrentWeek()`
     - Note:
        Changed in `weekChanged()`
     */
    var currentWeek = 1
    
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
    
    /// Picker from popup which edit number of lesson (tap on lesson while editing)
    var lessonNumberFromPicker: Int = 1

    /**
     Variable from segue which used when this `SheduleViewControler`
     is presented with initial lessons like in `SettingsTVC` with `Getting fresh shedule`
     and therefore lessons do not need to be updated from CoreData
      - Note: it used in `makeLessonShedule()` if `isFromSettingsGetFreshShedule || isFromGroups`
     */
    var lessonsFromSegue: [Lesson] = []
    
    /**
     Variable used in segue from `GroupAndTeachersVC` and `FavouriteVC`
     to push `Group` and then use this information to show, add or remove it from favourites
     */
    var groupFromSegue: Group?
        
    /**
     `true` when segue from`SettingsTVC` with `Getting fresh shedule`
     */
    var isFromSettingsGetFreshShedule: Bool = false
    
    /**
    `true` when segue from`GroupsAndTeacherVC` or `FavouriteVC`
    */
    var isFromGroupsAndTeacherOrFavourite: Bool = false
    
    /// Is need to scroll or not
    var isNeedToScroll: Bool = true
    
    /// `true` when group is in favourite
    var isFavourite: Bool = false
    
    /// Settings singleton
    var settings = Settings.shared
    
    /// Favourites singleton
    var favourites = Favourites.shared
    
    /// Array with day names
    var daysArray: [String] = [DayName.mounday.rawValue,
                               DayName.tuesday.rawValue,
                               DayName.wednesday.rawValue,
                               DayName.thursday.rawValue,
                               DayName.friday.rawValue,
                               DayName.saturday.rawValue]

    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Set up window
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        /// Presenting `GroupChooserViewController` if `settings.groupName == ""`
        presentGroupOrTeacherChooser(requestType: global.sheduleType)
        
        /// Setup navigationVC  and title
        setupNavigation()
        
        /// TableView delegate, dataSource, registration cell
        setupTableView()

        /// Start animating and show activityIndicator
        setupAtivityIndicator()
        
        /// Getting dayNumber and week of year from device Date()
        setupDate()
        
        /// Setting current week
        setupCurrentWeek()

        if isFromSettingsGetFreshShedule {
            /**
             Setup if is view controller presented from  `SettingsTVC`
             */
            self.navigationItem.rightBarButtonItems = [segmentBatButtonItem]
            self.weekSegmentControl.frame = CGRect(x: 0, y: 0, width: 90, height: weekSegmentControl.frame.height)
            
        } else if isFromGroupsAndTeacherOrFavourite {
            /**
             Setup if is view controller presented from  `GroupsAndTeacherVC` or ` FavouriteVC`
            */
            self.navigationItem.rightBarButtonItems = [segmentBatButtonItem, favouriteBarButtonItem]
            self.weekSegmentControl.frame = CGRect(x: 0, y: 0, width: 90, height: weekSegmentControl.frame.height)
            checkIfGroupInFavourites()

        } else if settings.groupName != "" || settings.teacherName != "" {
            /**
             Main setup
             */
            self.navigationItem.rightBarButtonItems = [segmentBatButtonItem]
            self.navigationItem.leftBarButtonItems = [self.editButtonItem]
            self.weekSegmentControl.frame = CGRect(x: 0, y: 0, width: 120, height: weekSegmentControl.frame.height)
            
            /// After reopen app, reload lessons and current time
            NotificationCenter.default.addObserver(self, selector:#selector(reloadAfterOpenApp), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
        
        /// Make server request or call `makeLessonsShedule()`
        if settings.isTryToRefreshShedule {
            getLessonsFromServer()
            settings.isTryToRefreshShedule = false
        } else {
            makeLessonsShedule()
        }
        
        /// If `isNeedToScroll` == true, scroll
        _ = isNeedToScroll ? scrollToCurrentOrNext() : nil
    }
    
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        setupNavigation()
    }

    
    // MARK: - SETUP functions
    
    private func setupTableView() {
        tableView.register(UINib(nibName: LessonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: LessonTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = tint
        } else {
            tableView.backgroundColor = .white
        }
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
        if !isFromSettingsGetFreshShedule && !isFromGroupsAndTeacherOrFavourite {
            setLargeTitleDisplayMode(.always)
            
            if global.sheduleType == .groups {
                self.navigationItem.title = settings.groupName.uppercased()
            } else if global.sheduleType == .teachers {
                self.navigationItem.title = "Мій розклад"
            }

        } else {
            setLargeTitleDisplayMode(.never)
        }

        self.navigationController?.navigationBar.isTranslucent = true
        self.tabBarController?.tabBar.isTranslucent = true
    }
    
    
    /// Function to set up currnet week in viewDidLoad
    func setupCurrentWeek() {
        if self.weekOfYear % 2 == 0 {
            self.currentWeekFromTodayDate = 1
            self.weekSegmentControl.selectedSegmentIndex = 0
            self.currentWeek = 1
        } else {
            self.currentWeekFromTodayDate = 2
            self.weekSegmentControl.selectedSegmentIndex = 1
            self.currentWeek = 2
        }
    }
    
    
    // MARK: - presentGroupChooser
    /// Func which present `FirstViewController`
    func presentGroupOrTeacherChooser(requestType: SheduleType) {
        if settings.groupName == "" && settings.teacherName == "" {
            
            guard let greetingVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: FirstViewController.identifier) as? FirstViewController else { return }
            
            guard let window = window else { return }

            window.rootViewController = greetingVC
            window.makeKeyAndVisible()
            
            let options: UIView.AnimationOptions = .transitionCrossDissolve
            greetingVC.modalTransitionStyle = .crossDissolve

            // The duration of the transition animation, measured in seconds.
            let duration: TimeInterval = 0.4

            UIView.transition(with: window, duration: duration, options: options, animations: {}, completion:
                { completed in })
        }
    }
    
    
    // MARK: - presentAddLesson
    /// Func which present `AddLessonViewController`
    func presentAddLesson() {
        guard let addLesson: AddLessonViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: AddLessonViewController.identifier) as? AddLessonViewController else { return }
        
        addLesson.lessons = fetchingCoreData()
        addLesson.currentWeek = self.currentWeek
        
        if #available(iOS 13, *) {
            self.present(addLesson, animated: true, completion: nil)
        } else {
            self.navigationController?.pushViewController(addLesson, animated: true)
        }
    }
    
    
    private func scrollToCurrentOrNext() {
        var indexPathToScroll = IndexPath(row: 0, section: 0)

        k: for section in 0..<self.lessonsForTableView.count {
            let day = lessonsForTableView[section]
            for row in 0..<day.value.count {
                let lesson = day.value[row]
                if lesson.lessonID == currentLessonId {
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
                if self.lessonsForTableView[indexPathToScroll.section].value.count > indexPathToScroll.row {
                    self.tableView.scrollToRow(at: indexPathToScroll, at: .top, animated: true)
                }
            }
        }
    }
    
    
    // MARK: - makeLessonsShedule
    /**
     Function which fetch lessons from CoreData and remake `[Lesson]` to `[(key: DayName, value: [Lesson])]`
     - Note: call in `weekChanged()` and after getting data from `getLessonsFromServer()`
     - Remark: make shedule only for one week.
     */
    func makeLessonsShedule() {
        var lessons: [Lesson] = []
        
        /// When the program is reopen, you need to update the time and the current and next lesson
        setupDate()
        (currentLessonId, nextLessonId) = getCurrentAndNextLesson(lessons: lessons, timeIsNowString: timeIsNowString, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
        
        if isFromSettingsGetFreshShedule || isFromGroupsAndTeacherOrFavourite {
            lessons = lessonsFromSegue
        } else {
            lessons = fetchingCoreData()
        }

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
        
        /// .sorted is sorting from mounday to saturday (must be in normal order)
        self.lessonsForTableView = [DayName.mounday: lessonMounday,
                                    DayName.tuesday: lessonTuesday,
                                    DayName.wednesday: lessonWednesday,
                                    DayName.thursday: lessonThursday,
                                    DayName.friday: lessonFriday,
                                    DayName.saturday: lessonSaturday].sorted{$0.key < $1.key}
        
        /// (self.activityIndicator != nil)  because if when we push information from another VC tableView can be not exist
        if self.activityIndicator != nil {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
        
        /// (self.tableView != nil)  because if when we push information from another VC tableView can be not exist
        if self.tableView != nil {
            self.tableView.isHidden = self.tableView.isHidden ? false : false
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Server
    /**
     Functon which getting data from server
     - note: This fuction call `updateCoreData(vc: SheduleViewController)`
     */
    private func getLessonsFromServer() {
        let serverLessons: Promise<[Lesson]> = global.sheduleType == .groups ? API.getStudentLessons(forGroupWithId: settings.groupID) : API.getTeacherLessons(forTeacherWithId: settings.teacherID)
        
        serverLessons.done({ [weak self] (lessons) in
            guard let this = self else { return }
            updateCoreData(vc: this, datum: lessons)
        }).catch({ [weak self] (error) in
            guard let this = self else { return }

            if error.localizedDescription == NetworkingApiError.lessonsNotFound.localizedDescription {
                let messageAlert = global.sheduleType == .groups ? "Розкладу для цієї групи не існує" : "Розкладу для цього викладача не існує"
                let actionTitle = global.sheduleType == .groups ? "Змінити групу" : "Змінити викладача"
                
                let alert = UIAlertController(title: nil, message: messageAlert, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (_) in
                    this.settings.groupName = ""
                    this.settings.teacherName = ""
                    this.presentGroupOrTeacherChooser(requestType: global.sheduleType)
                }))
                
                this.present(alert, animated: true, completion: {
                    this.settings.isTryToRefreshShedule = true
                })
            } else {
                let alert = UIAlertController(title: "Помилка", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Оновити", style: .default, handler: { (_) in
                    this.getLessonsFromServer()
                }))

                this.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    
    // MARK:- weekChanged
    /// Function that calls when the user tap on segment conrol to change current week
    @IBAction func weekChanged(_ sender: UISegmentedControl) {
        switch weekSegmentControl.selectedSegmentIndex {
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
    
    
    // MARK: - Favourites
    func checkIfGroupInFavourites() {
        if let strongGroup = groupFromSegue {
            if favourites.favouriteGroupsID.contains(strongGroup.groupID) {
                if let image = UIImage(named: "icons8-favourite-filled") {
                    favouriteButton.setImage(image, for: .normal)
                    isFavourite = true
                }
            }
        }
    }
    
    
    @IBAction func didPressFavouriteButton(_ sender: UIButton) {
        guard let strongGroup = groupFromSegue else { return }
        if isFavourite {
            if let image = UIImage(named: "icons8-favourite-add") {
                for i in 0..<favourites.favouriteGroupsID.count {
                    if strongGroup.groupID == favourites.favouriteGroupsID[i] {
                        favouriteButton.setImage(image, for: .normal)
                        _ = favourites.favouriteGroupsNames.remove(at: i)
                        _ = favourites.favouriteGroupsID.remove(at: i)
                        isFavourite = false
                        return
                    }
                }
            }
        } else {
            if let image = UIImage(named: "icons8-favourite-filled") {
                favouriteButton.setImage(image, for: .normal)
                favourites.favouriteGroupsNames.append(strongGroup.groupFullName)
                favourites.favouriteGroupsID.append(strongGroup.groupID)

                isFavourite = true
            }
        }
    }
    
    
    // MARK: - Other functions
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
    
    
    @objc func reloadAfterOpenApp() {
        makeLessonsShedule()
        setLargeTitleDisplayMode(.never)
//        setupNavigation()
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
//            self.setLargeTitleDisplayMode(.always)
//        }
    }
}
