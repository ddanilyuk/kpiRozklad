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
import WatchConnectivity


/**
 ## Important things ##
 
 1.  All in tableView works with `lessonsForTableView` variable, but Core Data saving `[Lesson]`
 2. `getLessonsFromServer()` receives data from the server and call `updateCoreData(vc: SheduleViewController, datum:  [Lesson])` where datum is `[Lesson]` from API
 3. `fetchingCoreData(vc: SheduleViewController) -> [Lesson]` return `[Lesson]` from Core Data
 4. `makeLessonsShedule()` remake `[Lesson]` to `[(day: DayName, lessons: [Lesson])]`
 */
class SheduleViewController: UIViewController{

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
    var lessonsForTableView: [(day: DayName, lessons: [Lesson])] = [(day: DayName.mounday, lessons: []),
                                                                    (day: DayName.tuesday, lessons: []),
                                                                    (day: DayName.wednesday, lessons: []),
                                                                    (day: DayName.thursday, lessons: []),
                                                                    (day: DayName.friday, lessons: []),
                                                                    (day: DayName.saturday, lessons: [])]
                                                                  
        
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
    
    
    var isTeachersShedule: Bool = false
    
    
    var teacherFromSegue: Teacher?

    /// Is need to scroll or not
    var isNeedToScroll: Bool = true
    
    /// `true` when group is in favourite
    var isFavourite: Bool = false
    
    /// Settings singleton
    let settings = Settings.shared
    
    /// Favourites singleton
    let favourites = Favourites.shared
    
    /// Array with day names
    var daysArray: [String] = DayName.allCases.map { (dayName: DayName) -> String in
        return dayName.rawValue
    }
    
    ///`isEditInserts` responsible for ensuring that after loading from `viewDidLoad` not to update `tableView.contentInset` to -20
    var isEditInserts: Bool = false
    
    /// Variable used in setEditing to store tableView contentHeight before editing
    var defaultContentInsets: UIEdgeInsets?
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Set up window
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        /// Presenting `GroupChooserViewController` if `settings.groupName == ""`
        presentGroupOrTeacherChooser(requestType: settings.sheduleType)
        
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
            
        } else if isTeachersShedule {
            /**
             Setup if this VC  used to show teacher lessons (not main shedule)
            */
            self.navigationItem.rightBarButtonItems = [segmentBatButtonItem, favouriteBarButtonItem]
            self.weekSegmentControl.frame = CGRect(x: 0, y: 0, width: 90, height: weekSegmentControl.frame.height)
            checkIfTeacherInFavourites()

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
            
            getLessonsFromServer(isMainShedule: !isTeachersShedule)
            
            settings.isTryToRefreshShedule = false
        } else {
            makeLessonsShedule()
        }
        
        /// If `isNeedToScroll` == true, scroll
        _ = isNeedToScroll ? scrollToCurrentOrNext() : nil
        
        /// Set `isEditInserts` for `tableView.contentInset`
        isEditInserts = true
        
        
        
        
//        let session = WCSession.default

        
        
        
//        if WCSession.isSupported() {
//            do {
//                let userInfo: [String: String] = ["lessons": "\(fetchingCoreData(managedContext: managedContext).count)"]
//                print(userInfo)
//                try session.updateApplicationContext(userInfo)
//            } catch {
//                print("Error: \(error)")
//            }
//        }
        
        
    }
    
    
    // MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        /**
         Some about why is -20 in `tableView.contentInset`
         In IOS 13.4 after changing large title from .never and then to .always (this changing need because scroll view works incorrectly),
         at bottom of table view appear strange line which is 20px height.
         And  variable `isEditInserts`,  code in `viewWillAppear` and `viewWillDisappear` fix this problem.
         */
        if !isFromSettingsGetFreshShedule && !isFromGroupsAndTeacherOrFavourite && !isTeachersShedule && !isTeachersShedule {
            print("MAIN")
            setLargeTitleDisplayMode(.always)
            
            if #available(iOS 13.0, *) {
                if self.navigationController?.navigationBar.frame.size.height ?? 44 > CGFloat(50) {
                    print("LARGE")
                    if isEditInserts {
                        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -20, right: 0)
                    } else {
                        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    }
                    
                    isEditInserts = false
                } else {
                    self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -20, right: 0)
                }
            }
        } else {
            setLargeTitleDisplayMode(.never)
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        
        if WCSession.isSupported() {
            let session = WCSession.default
            do {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let managedContext = appDelegate.persistentContainer.viewContext
                
                let lessons = fetchingCoreData(managedContext: managedContext)
                
                let encoder = JSONEncoder.init()
                
                let dataLessons = try encoder.encode(lessons)
                
                let name = isTeachersShedule ? settings.teacherName : settings.groupName
                
                let currentColourData = settings.cellCurrentColour.encode()
                let nextColourData = settings.cellNextColour.encode()

                
//                let some = UIColor(\)
                
                
                
                let dictionary: [String: Any] = ["lessons": dataLessons, "time": Date().timeIntervalSince1970, "name": name, "currentColourData": currentColourData, "nextColourData": nextColourData]
//                let dictionary: [String: Any] = ["lessons": dataLessons, "name": name, "currentColourData": currentColourData, "nextColourData": nextColourData]

                print(dictionary)
                try session.updateApplicationContext(dictionary)
                
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    
    // MARK: - viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        /**
         If view disappears with small title, set ` setLargeTitleDisplayMode(.never)`
         And if view disappears with llarge title, set ` setLargeTitleDisplayMode(.always)`
         */
        if self.navigationController?.navigationBar.frame.size.height ?? 44 > CGFloat(50) {
            setLargeTitleDisplayMode(.always)
        } else {
            setLargeTitleDisplayMode(.never)

            if #available(iOS 13.0, *) {
                /**
                 The part of code in `#available(iOS 13.0, *)` is need for update `tableView.contentInset`
                 if `current` or `next` lesson is not at top `lessonsForTableView`
                 */
                let firstLessonValue = lessonsForTableView[0].lessons.count != 0 ?  Int(lessonsForTableView[0].lessons[0].lessonID) ?? 0 : -1
                let next = Int(nextLessonId) ?? 0
                let current = Int(currentLessonId) ?? 0

                if self.isTeachersShedule || self.isFromGroupsAndTeacherOrFavourite {
                    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                } else if ((next != firstLessonValue) && (current != firstLessonValue)) {
                    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -20, right: 0)
                }
            }
        }
    }
    
    
    // MARK: - SETUP functions
    
    private func setupTableView() {
        tableView.register(UINib(nibName: LessonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: LessonTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = tint
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
        self.navigationController?.navigationBar.prefersLargeTitles = false

        if isTeachersShedule {
            if UIScreen.main.nativeBounds.height < 1140 {
                self.navigationItem.title = "Зараз \(self.currentWeekFromTodayDate) тиж."
            } else {
                self.navigationItem.title = "Зараз \(self.currentWeekFromTodayDate) тиждень"
            }
            setLargeTitleDisplayMode(.never)
        } else if !isFromSettingsGetFreshShedule && !isFromGroupsAndTeacherOrFavourite && !isTeachersShedule {
            setLargeTitleDisplayMode(.always)
            
            if settings.sheduleType == .groups {
                self.navigationItem.title = settings.groupName.uppercased()
            } else if settings.sheduleType == .teachers {
                if UIScreen.main.nativeBounds.height < 1140 {
                    self.navigationItem.title = "Розклад"
                } else {
                    self.navigationItem.title = "Мій розклад"
                }
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
    /**
     Funcion which present `FirstViewController`
    */
    func presentGroupOrTeacherChooser(requestType: SheduleType) {
        if settings.groupName == "" && settings.teacherName == "" {
            
            guard let greetingVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: FirstViewController.identifier) as? FirstViewController else { return }
            
            guard let window = window else { return }

            window.rootViewController = greetingVC
            window.makeKeyAndVisible()
            
            greetingVC.modalTransitionStyle = .crossDissolve

            UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: {}, completion:
                { completed in })
        }
    }
    
    
    // MARK: - presentAddLesson
    /**
     Funcion which present `AddLessonViewController`
     */
    func presentAddLesson() {
        guard let addLesson: AddLessonViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: AddLessonViewController.identifier) as? AddLessonViewController else { return }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        addLesson.lessons = fetchingCoreData(managedContext: managedContext)
        addLesson.currentWeek = self.currentWeek
        
        if #available(iOS 13, *) {
            self.present(addLesson, animated: true, completion: nil)
        } else {
            self.navigationController?.pushViewController(addLesson, animated: true)
        }
    }
    
    
    // MARK: - scrollToCurrentOrNext
    /**
     Function which scroll to current or next if `isNeedToScroll`
     */
    private func scrollToCurrentOrNext() {
        var indexPathToScroll = IndexPath(row: 0, section: 0)

        k: for section in 0..<self.lessonsForTableView.count {
            let day = lessonsForTableView[section]
            for row in 0..<day.lessons.count {
                let lesson = day.lessons[row]
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
            self.isNeedToScroll = false
            
            self.isEditInserts = false
            DispatchQueue.main.async {
                if self.lessonsForTableView[indexPathToScroll.section].lessons.count > indexPathToScroll.row {
                    let window = UIApplication.shared.keyWindow
                    
                    
                    let сontentHeight = self.tableView.contentSize.height - self.tableView.contentOffset.y
                    let safeAreaHeight = screenHeight - (window?.safeAreaInsets.top ?? 0) - (window?.safeAreaInsets.bottom ?? 0)

                    /// if `current` or `next` lesson is at top `lessonsForTableView`
                    if (indexPathToScroll.section == 0 && indexPathToScroll.row == 0) || (сontentHeight < safeAreaHeight) {
                        self.navigationController?.navigationBar.prefersLargeTitles = true
                    } else {
                        self.isEditInserts = true

                        self.navigationController?.navigationBar.prefersLargeTitles = false
                    }

                    self.tableView.scrollToRow(at: indexPathToScroll, at: .top, animated: true)
                    
                    if !self.isFromGroupsAndTeacherOrFavourite && !self.isFromSettingsGetFreshShedule {
                        self.navigationController?.navigationBar.prefersLargeTitles = true
                    }
                    /**
                     In IOS 13.4 after changing large title from .never and then to .always (this changing need because scroll view works incorrectly),
                     at bottom of table view appear strange line which is 20px height. This is how i fix it.
                     */
                    if #available(iOS 13.0, *) {
                        if (indexPathToScroll.section == 0 && indexPathToScroll.row == 0) && self.isFromSettingsGetFreshShedule {
                            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -20, right: 0)
                        } else if (indexPathToScroll.section == 0 && indexPathToScroll.row == 0) || self.isTeachersShedule || self.isFromGroupsAndTeacherOrFavourite {
                            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                        } else {
                            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -20, right: 0)
                        }
                    }
                }
            }
            
        }
        
    }
    
    
    // MARK: - makeLessonsShedule
    /**
     Function which fetch lessons from CoreData and remake `[Lesson]` to `[(day: DayName, lessons: [Lesson])]`
     - Note: call in `weekChanged()` and after getting data from `getLessonsFromServer()`
     - Remark: make shedule only for one week.
     */
    func makeLessonsShedule() {
        var lessons: [Lesson] = []
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        /// When the program is reopen, you need to update the time and the current and next lesson
        if (isFromSettingsGetFreshShedule || isFromGroupsAndTeacherOrFavourite ||  isTeachersShedule) {
            lessons = lessonsFromSegue
        } else {
            lessons = fetchingCoreData(managedContext: managedContext)
        }

        setupDate()
        (nextLessonId, currentLessonId) = getCurrentAndNextLesson(lessons: lessons, timeIsNowString: timeIsNowString, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
        
        /// Getting lesson for first week and second
        let lessonsFirst: [Lesson] = lessons.filter { Int($0.lessonWeek) == 1 }
        let lessonsSecond: [Lesson] = lessons.filter { Int($0.lessonWeek) == 2 }
        let currentLessonWeek = currentWeek == 1 ? lessonsFirst : lessonsSecond
        
        var sortedDictionary = Dictionary(grouping: currentLessonWeek) { $0.dayName }
        for day in DayName.allCases {
            if sortedDictionary[day] == nil {
                sortedDictionary[day] = []
            }
        }
        
        var result: [(day: DayName, lessons: [Lesson])] = []
        
        let keys = sortedDictionary.keys.sorted()
        keys.forEach { dayName in
            if let lessons: [Lesson] = sortedDictionary[dayName] {
                result.append((day: dayName, lessons: lessons))
            } else {
                result.append((day: dayName, lessons: []))
            }
        }
        self.lessonsForTableView = result
        
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
        
        /// Scroll if need
        if isNeedToScroll {
            self.scrollToCurrentOrNext()
        }
    }
    
    
    // MARK: - Server
    /**
     Functon which getting data from server
     - note: This fuction call `updateCoreData(vc: SheduleViewController)`
     */
    private func getLessonsFromServer(isMainShedule: Bool = true) {
        let serverLessonsOptional: Promise<[Lesson]>?
        
        if isMainShedule {
            serverLessonsOptional = settings.sheduleType == .groups ? API.getStudentLessons(forGroupWithId: settings.groupID) : API.getTeacherLessons(forTeacherWithId: settings.teacherID)
        } else {
            serverLessonsOptional = API.getTeacherLessons(forTeacherWithId: Int(teacherFromSegue?.teacherID ?? "") ?? 0)
        }
        
        guard let serverLessons = serverLessonsOptional else { return }
                
        serverLessons.done({ [weak self] (lessons) in
            guard let this = self else { return }

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
                
            if isMainShedule {
                this.isNeedToScroll = true
                updateCoreData(lessons: lessons, managedContext: managedContext) {
                    this.makeLessonsShedule()
                }
            } else {
                this.lessonsFromSegue = lessons
                this.makeLessonsShedule()
            }
        }).catch({ [weak self] (error) in
            guard let this = self else { return }

            if error.localizedDescription == NetworkingApiError.lessonsNotFound.localizedDescription {
                let messageAlert = (this.settings.sheduleType == .groups || !isMainShedule) ? "Розкладу для цієї групи не існує" : "Розкладу для цього викладача не існує"
                let actionTitle = (this.settings.sheduleType == .groups || !isMainShedule) ? "Змінити групу" : "Змінити викладача"
                
                let alert = UIAlertController(title: nil, message: messageAlert, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (_) in
                    this.settings.groupName = ""
                    this.settings.teacherName = ""
                    this.presentGroupOrTeacherChooser(requestType: this.settings.sheduleType)
                }))
                
                this.present(alert, animated: true, completion: {
                    this.settings.isTryToRefreshShedule = true
                })
            } else {
                let alert = UIAlertController(title: "Помилка", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Оновити", style: .default, handler: { (_) in
                    _ = isMainShedule ? this.getLessonsFromServer() :                         this.getLessonsFromServer(isMainShedule: false)
                }))

                this.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    
    // MARK:- weekChanged
    /**
     Function that calls when the user tap on segment conrol to change current week
     */
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
    
    
    func checkIfTeacherInFavourites() {
        if let strongTeacher = teacherFromSegue {
            if favourites.favouriteTeachersID.contains(Int(strongTeacher.teacherID) ?? 0) {
                if let image = UIImage(named: "icons8-favourite-filled") {
                    favouriteButton.setImage(image, for: .normal)
                    isFavourite = true
                }
            }
        }
    }
    
    
    @IBAction func didPressFavouriteButton(_ sender: UIButton) {
        var idToFindOrAdd: Int = 0
        var nameToFindOrAdd: String = ""
        
        if isTeachersShedule {
            guard let strongTeacher = teacherFromSegue else { return }
            idToFindOrAdd = Int(strongTeacher.teacherID) ?? 0
            nameToFindOrAdd = strongTeacher.teacherName == "" ? strongTeacher.teacherFullName : strongTeacher.teacherName
        } else {
            guard let strongGroup = groupFromSegue else { return }
            idToFindOrAdd = Int(strongGroup.groupID)
            nameToFindOrAdd = strongGroup.groupFullName
        }
        
        if isFavourite {
            if let image = UIImage(named: "icons8-favourite-add") {
                let favouritesID = isTeachersShedule ? favourites.favouriteTeachersID : favourites.favouriteGroupsID
                
                for i in 0..<favouritesID.count {
                    if idToFindOrAdd == favouritesID[i] {
                        favouriteButton.setImage(image, for: .normal)
                        _ = isTeachersShedule ? favourites.favouriteTeachersNames.remove(at: i) : favourites.favouriteGroupsNames.remove(at: i)
                        _ = isTeachersShedule ? favourites.favouriteTeachersID.remove(at: i) : favourites.favouriteGroupsID.remove(at: i)
                        isFavourite = false
                        return
                    }
                }
            }
        } else {
            if let image = UIImage(named: "icons8-favourite-filled") {
                favouriteButton.setImage(image, for: .normal)
                _ = isTeachersShedule ? favourites.favouriteTeachersNames.append(nameToFindOrAdd) : favourites.favouriteGroupsNames.append(nameToFindOrAdd)
                _ = isTeachersShedule ? favourites.favouriteTeachersID.append(idToFindOrAdd) : favourites.favouriteGroupsID.append(idToFindOrAdd)
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
    }
}

