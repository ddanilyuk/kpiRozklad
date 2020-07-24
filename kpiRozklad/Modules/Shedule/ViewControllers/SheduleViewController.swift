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

#if canImport(WidgetKit)
import WidgetKit
#endif


/**
 ## Important things ##
 
 1.  All in tableView works with `lessonsForTableView` variable, but Core Data saving `[Lesson]`
 2. `getLessonsFromServer()` receives data from the server and call `updateCoreData(vc: SheduleViewController, datum:  [Lesson])` where datum is `[Lesson]` from API
 3. `fetchingCoreData(vc: SheduleViewController) -> [Lesson]` return `[Lesson]` from Core Data
 4. `makeLessonsShedule()` remake `[Lesson]` to `[(day: DayName, lessons: [Lesson])]`
 */
class SheduleViewController: UIViewController {

    // MARK: - Variables
    var window: UIWindow?
    
    @IBOutlet weak var tableView: UITableView!
    
    /// Week switcher (1 and 2 week)
    @IBOutlet weak var weekSegmentControl: UISegmentedControl!
    
    /// Loading from server indicator
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /// Favourite bar button item
    @IBOutlet weak var favouriteBarButtonItem: UIBarButtonItem!
    
    /// Bar button item with segment control (which change week)
    @IBOutlet weak var segmentBatButtonItem: UIBarButtonItem!
    
    /// Favourite button
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
        Set  up in `setupCurrentDate()`
     */
    var currentWeekFromTodayDate: WeekType = .first
    
    /// Current  week which user chosed
    var currentWeek: WeekType = .first
    
    /// Used in `makeLessonShedule`
    var dayNumberFromCurrentDate = 0
    
    /// Time is Now from device
    var timeIsNowString = String()
    
    /**
     Lesson ID of **current** lesson
     Updated in `makeLessonShedule()`
     */
    var currentLessonId: Int = 0
    
    /**
     Lesson ID of **next** lesson
     Updated in `makeLessonShedule()`
     */
    var nextLessonId: Int = 0
    
    /// Picker from popup which edit number of lesson (tap on lesson while editing)
    var lessonNumberFromPicker: Int = 1

    /**
     Variable from segue which used when this `SheduleViewControler`
     is presented with initial lessons like in `SettingsTVC` with `Getting fresh shedule`
     and therefore lessons do not need to be updated from CoreData.
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
    
    /// True when shown teacher lesson (not group)
    var isTeachersShedule: Bool = false
    
    /// Teacher from segue
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
    var daysArray: [String] = DayName.allCases.map { $0.rawValue }
    
    var isEditInsets: Bool = true
    
    
    // MARK: - override viewController funcs
    override func viewDidLoad() {
        super.viewDidLoad()

        /// Set up window
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        /// Presenting `GroupChooserViewController` if `settings.groupName == ""`
        presentGroupOrTeacherChooser(requestType: settings.sheduleType)
        
        /// Getting dayNumber and week of year from device Date()
        setupCurrentDate()
        
        /// Setup navigationVC and title
        setupNavigation()
        
        /// TableView delegate, dataSource, registration cell
        setupTableView()

        /// Start animating and show activityIndicator
        setupAtivityIndicator()

        /// Setup weekSwitch color
        setupWeekSegmentControl()

        /// Setup weekSegmentControll and other navigation items
        setupNavigationItems()
        
        /// Make server request or call `makeLessonsShedule()`
        if settings.isTryToRefreshShedule {
            getLessonsFromServer(isMainShedule: !isTeachersShedule)
        } else {
            makeLessonsShedule()
        }
        
        DispatchQueue.main.async {
            _ = self.isNeedToScroll ? self.scrollToCurrentOrNext() : nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 13.0, *) {
            if isLargeTitleAvailable() && !settings.isTryToRefreshShedule && isEditInsets {
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -20, right: 0)
            } else {
                isEditInsets = false
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        isEditInsets = true
        if !isFromSettingsGetFreshShedule && !isFromGroupsAndTeacherOrFavourite && !isTeachersShedule && !isTeachersShedule {
            setLargeTitleDisplayMode(.always)
        } else {
            setLargeTitleDisplayMode(.never)
        }
        self.viewDidLayoutSubviews()
        

        
        reloadDataOnAppleWatch()
    }

    override func viewWillDisappear(_ animated: Bool) {
        /**
         If view disappears with small title, set ` setLargeTitleDisplayMode(.never)`
         And if view disappears with llarge title, set ` setLargeTitleDisplayMode(.always)`
         */
        if self.navigationController?.navigationBar.frame.size.height ?? 44 > CGFloat(50) {
            setLargeTitleDisplayMode(.always)
        } else {
            setLargeTitleDisplayMode(.never)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !settings.isShowWhatsNewInVersion2Point0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                guard let whatsNewVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: WhatsNewViewController.identifier) as? WhatsNewViewController else { return }
                if #available(iOS 13.0, *) {
                    self.present(whatsNewVC, animated: true, completion: nil)
                } else {
                    self.navigationController?.pushViewController(whatsNewVC, animated: true)
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

    private func setupCurrentDate() {
        let result = getTimeAndDayNumAndWeekOfYear()
        timeIsNowString = result.timeIsNowString
        dayNumberFromCurrentDate = result.dayNumberFromCurrentDate
        self.currentWeekFromTodayDate = result.weekOfYear % 2 == 0 ? .first : .second
    }
    
    private func setupAtivityIndicator() {
        activityIndicator.startAndShow()
        tableView.isHidden = true
        self.view.bringSubviewToFront(activityIndicator)
    }
    
    private func setupNavigation() {
        if isTeachersShedule {
            setLargeTitleDisplayMode(.never)
            if UIScreen.main.nativeBounds.height < 1140 {
                self.navigationItem.title = "Зараз \(self.currentWeekFromTodayDate.rawValue) т."
            } else {
                self.navigationItem.title = "Зараз \(self.currentWeekFromTodayDate.rawValue) тиждень"
            }
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
    
    private func setupWeekSegmentControl() {
        
        var titleTextAttributesNormal = [NSAttributedString.Key.foregroundColor: UIColor.blue]
        let titleTextAttributesSelected = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        if #available(iOS 13.0, *) {
            titleTextAttributesNormal = [NSAttributedString.Key.foregroundColor: UIColor.link]
        }

        weekSegmentControl.setTitleTextAttributes(titleTextAttributesNormal, for: .normal)
        weekSegmentControl.setTitleTextAttributes(titleTextAttributesSelected, for: .selected)
    }
    
    private func setupNavigationItems() {
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
    }
    
    
    // MARK: - PRESENT functions
    /**
     Funcion which present `FirstViewController`
    */
    func presentGroupOrTeacherChooser(requestType: SheduleType) {
        if settings.groupName == "" && settings.teacherName == "" {
            guard let greetingVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: BoardingViewController.identifier) as? BoardingViewController else { return }
            
            guard let window = window else { return }

            window.rootViewController = greetingVC
            window.makeKeyAndVisible()
            
            greetingVC.modalTransitionStyle = .crossDissolve
            UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: {}, completion:
                { completed in })
        }
    }
    
    /**
     Funcion which present `AddLessonViewController`
     */
    func presentNewLesson() {
        guard let newLessonViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: NewLessonViewController.identifier) as? NewLessonViewController  else { return }
        newLessonViewController.delegate = self
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        newLessonViewController.lessons = fetchingCoreData(managedContext: managedContext)
        let navigationController = UINavigationController()
        
        navigationController.viewControllers = [newLessonViewController]
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.barTintColor = tint
        
        if #available(iOS 13, *) {
            self.present(navigationController, animated: true, completion: nil)
        } else {
            self.navigationController?.pushViewController(newLessonViewController, animated: true)
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
                if lesson.id == currentLessonId {
                    indexPathToScroll = IndexPath(row: row, section: section)
                    break k
                } else if lesson.id == nextLessonId {
                    indexPathToScroll = IndexPath(row: row, section: section)
                    break k
                }
            }
        }
        
        /// (self.tableView != nil)  because if when we push information from another VC tableView can be not exist
        if self.tableView != nil {
            self.isNeedToScroll = false
            if (self.lessonsForTableView[indexPathToScroll.section].lessons.count > indexPathToScroll.row) && !(indexPathToScroll.row == 0 && indexPathToScroll.section == 0) {
                self.tableView.contentOffset.y = self.heightDifferenceBetweenTopRowAndNavBar()
                self.tableView.scrollToRow(at: indexPathToScroll, at: .top, animated: true)
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

        setupCurrentDate()
        (nextLessonId, currentLessonId) = getCurrentAndNextLesson(lessons: lessons, timeIsNowString: timeIsNowString, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
    
        /// Getting lesson for first week and second
        let lessonsFirst: [Lesson] = lessons.filter { $0.lessonWeek == .first }
        let lessonsSecond: [Lesson] = lessons.filter { $0.lessonWeek == .second }
        
        /// If lessonsForTableView is empty, we need to setup which weekToShow
        if lessonsForTableView.allSatisfy({ $1.count == 0 }) {
            if lessonsFirst.count != 0 {
                if nextLessonId == lessonsFirst[0].id {
                    self.weekSegmentControl.selectedSegmentIndex = 0
                    self.currentWeek = .first
                }
            }
            if lessonsSecond.count != 0 {
                if nextLessonId == lessonsSecond[0].id {
                    self.weekSegmentControl.selectedSegmentIndex = 1
                    self.currentWeek = .second
                }
            }
            self.currentWeek = currentWeekFromTodayDate
            self.weekSegmentControl.selectedSegmentIndex = currentWeek == .first ? 0 : 1
        }
        
        let currentLessonWeek = currentWeek == .first ? lessonsFirst : lessonsSecond
        
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
            self.activityIndicator.stopAndHide()
        }
        
        /// (self.tableView != nil)  because if when we push information from another VC tableView can be not exist
        if self.tableView != nil {
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
        view.layoutSubviews()

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
            serverLessonsOptional = API.getTeacherLessons(forTeacherWithId: teacherFromSegue?.teacherID ?? 0)
        }
        
        guard let serverLessons = serverLessonsOptional else { return }
                
        serverLessons.done({ [weak self] (lessons) in
            guard let this = self else { return }

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
                
            if isMainShedule {
                updateCoreData(lessons: lessons, managedContext: managedContext) {
                    /// Make new lessons
                    this.makeLessonsShedule()
                    this.settings.isTryToRefreshShedule = false
                    
                    this.isNeedToScroll = true
                    DispatchQueue.main.async {
                    _ = this.isNeedToScroll ? this.scrollToCurrentOrNext() : nil
                    }

                    /// Edit updated time
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd.MM.yyyy"
                    this.settings.sheduleUpdateTime = formatter.string(from: Date())
                    
                    /// Reload widget
                    if #available(iOS 14.0, *) {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    this.view.layoutSubviews()
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
                currentWeek = .first
                makeLessonsShedule()
                tableView.reloadData()
            case 1:
                currentWeek = .second
                makeLessonsShedule()
                tableView.reloadData()
            default:
                break
        }
    }
    
    
    // MARK: - Favourites
    
    func checkIfGroupInFavourites() {
        if let strongGroup = groupFromSegue {
            _ = favourites.favouriteGroupsID.contains(strongGroup.groupID) ? setButtonActive() : nil
        }
    }
    
    func checkIfTeacherInFavourites() {
        if let strongTeacher = teacherFromSegue {
            _ = favourites.favouriteTeachersID.contains(strongTeacher.teacherID) ? setButtonActive() : nil
        }
    }
    
    func setButtonActive() {
        if let image = UIImage(named: "icons8-favourite-filled") {
            favouriteButton.setImage(image, for: .normal)
            isFavourite = true
        }
    }
    
    @IBAction func didPressFavouriteButton(_ sender: UIButton) {
        var idToFindOrAdd: Int = 0
        var nameToFindOrAdd: String = ""
        
        if isTeachersShedule {
            guard let strongTeacher = teacherFromSegue else { return }
            idToFindOrAdd = strongTeacher.teacherID
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
    
    func heightDifferenceBetweenTopRowAndNavBar() -> CGFloat {
        let navBar = navigationController?.navigationBar
        let whereIsNavBarInTableView = tableView.convert(navBar!.bounds, from: navBar)
        let safeAreaTopInset = window?.safeAreaInsets.top ?? 0
        return safeAreaTopInset + whereIsNavBarInTableView.height + 35.0 * 2
    }
    
    func reloadDataOnAppleWatch() {
        if WCSession.isSupported() {
            print("Session supported")
            let session = WCSession.default
            do {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let managedContext = appDelegate.persistentContainer.viewContext
                
                let lessons = fetchingCoreData(managedContext: managedContext)
                
                let encoder = JSONEncoder.init()
                let dataLessons = try encoder.encode(lessons)
                let groupOrTeacherName = isTeachersShedule ? settings.teacherName : settings.groupName
                
                let currentColourData = settings.cellCurrentColour.encode()
                let nextColourData = settings.cellNextColour.encode()
                
                let dictionary: [String: Any] = ["lessons": dataLessons,
                                                 // "time": Date().timeIntervalSince1970,
                                                 "groupOrTeacherName": groupOrTeacherName,
                                                 "currentColourData": currentColourData,
                                                 "nextColourData": nextColourData]
//                try session.updateApplicationContext(dictionary)
                session.sendMessage(dictionary, replyHandler: nil) { error in
                    print(error.localizedDescription)
                }
                
                print("Session data sended")
            } catch {
                print("Error: \(error)")
            }
        }
    }
}


extension SheduleViewController: NewLessonViewControllerDelegate {
    func newLessonAdded() {
        makeLessonsShedule()
    }
}
