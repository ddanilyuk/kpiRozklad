//
//  AddLessonViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 16.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

class AddLessonViewController: UIViewController {
    
    /// Lessons from seque
    var lessons: [Lesson] = []
    
    /// Lessons from server
    var serverLessons: [Lesson] = []
    
    /// Current week from seque
    var currentWeek: Int = 0
    
    /// Unical lessons without repeating
    var unicalLessons: [Lesson] = []
    
    /// IDs from unical lessons
    /// - Note: used for creating new unical lesson ID
    var unicalIDs: [String] = []
    
    /// Unical `lesson.lessonName` from `unicalLessons`
    /// - Note: calls in `getUnicalLessons()`
    var unicalNames: [String] = []
    
    /// Array possible number of pairs
    var arrayPairs = ["1 пара", "2 пара", "3 пара", "4 пара", "5 пара", "6 пара"]
    
    /// Array possible lessonTypes
    var arrayTypePairs: [LessonType] = []

    /// **PICKERs VARIABLES**
    
    /// Lesson name default is `unicalLessons[0].lessonName`
    var lessonName = String()
    
    /// Lesson type default is `DayName.empty`
    var lessonType: LessonType = LessonType.empty
    
    /// Lesson day default is `DayName.mounday`
    var lessonDay: DayName = DayName.mounday
    
    /// Lesson number default is `1`
    var lessonNumber: Int = 1
    
    /// Day number of choosen day
    var dayNumber = 1
    
    /// Settings
    var settings = Settings.shared

    /// Lesson Name + Lesson Type
    @IBOutlet weak var lessonPickerView: UIPickerView!
    
    /// Lesson Day
    @IBOutlet weak var dayPickerView: UIPickerView!
    
    /// Lesson Number
    @IBOutlet weak var numberLessonPickerView: UIPickerView!
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Getting Unical Lesson + IDs
        getUnicalLessons(lessons: lessons)
        getUnicalIDs(lessons: lessons)
        
        server()

        setupPickers()
        
        setupDefaultValues()
    }

    
    private func setupDefaultValues() {
        freeTimeInDay(dayNumber: dayNumber)
        possibleTypeOfLessons(lessonNameToCheck: unicalNames[0])
        
        lessonNumber = Int(String(arrayPairs[0][..<1])) ?? 1
        lessonType = arrayTypePairs[0]
    }
    
    
    private func setupPickers() {
        lessonPickerView.delegate = self
        lessonPickerView.dataSource = self
        
        dayPickerView.delegate = self
        dayPickerView.dataSource = self
        
        numberLessonPickerView.delegate = self
        numberLessonPickerView.dataSource = self
    }
    
    
    // MARK: - getUnicalLessons
    func getUnicalLessons(lessons: [Lesson]) {
        for lesson in lessons {
            if !unicalNames.contains(lesson.lessonName){
                unicalLessons.append(lesson)
                getUnicalNames(lessons: lessons)
            }
        }
        if unicalLessons.count != 0 {
            lessonName = unicalLessons[0].lessonName != "" ? unicalLessons[0].lessonName : unicalLessons[0].lessonFullName
        }
        
    }
    
    
    func freeTimeInDay(dayNumber: Int) {
        var array = ["1 пара", "2 пара", "3 пара", "4 пара", "5 пара", "6 пара"]

        for lesson in lessons {
            if Int(lesson.dayNumber) ?? 0 == dayNumber && Int(lesson.lessonWeek) == currentWeek {
                if let index = array.firstIndex(of: "\(lesson.lessonNumber) пара") {

                    array.remove(at: index)
                }
            }
        }
        self.arrayPairs = array
    }
    
    
    func possibleTypeOfLessons(lessonNameToCheck: String) {
        let lessonsToFindExist = serverLessons.count != 0 ? serverLessons : lessons
        
        var typeArr: [LessonType] = []
        
        for lesson in lessonsToFindExist {
            if lessonNameToCheck == lesson.lessonName {
                if !typeArr.contains(lesson.lessonType) {
                    typeArr.append(lesson.lessonType)
                }
            }
        }
        arrayTypePairs = typeArr
    }
    
    
    // MARK: - getUnicalIDs
    func getUnicalIDs(lessons: [Lesson]) {
        unicalIDs = []
        for lesson in unicalLessons {
            unicalIDs.append(lesson.lessonID)
        }
    }
    
    
    // MARK: - getUnicalNames
    func getUnicalNames(lessons: [Lesson]) {
        unicalNames = []
        for lesson in unicalLessons {
            unicalNames.append(lesson.lessonName)
        }
    }
        
    
    // MARK: - didPressAddLesson
    @IBAction func didPressAddLesson(_ sender: UIButton) {
        /// Variable lesson which already exist (and use it)
        var similarLesson: Lesson?
        
        /// Some groups have `"лек"` but default is `"Лек"` and we equate this
        let lessonType2 = lessonType == LessonType.лек1 ? LessonType.лек2 : nil

        /// Finding `lesson` which already exist (and use it)

        let lessonsToFindExist = serverLessons.count != 0 ? serverLessons : lessons

        for lesson in lessonsToFindExist {
            if lessonName == lesson.lessonName && lessonType == lesson.lessonType {
                similarLesson = lesson
                break
            }
        }

        
        /// Guarding similar lesson
        guard let sameLessonButInDifferentTime = similarLesson else { return }
        
        /// Getting timeStart & timeEnd
        let time = getTimeFromLessonNumber(lessonNumber: String(lessonNumber))
        let timeStart = time.timeStart
        let timeEnd = time.timeEnd
        
        /// Randoming ID which is not already exist
        var ID = Int.random(in: 0 ..< 9999)
        while unicalIDs.contains(String(ID)) {
            ID = Int.random(in: 0 ..< 9999)
        }
        
        /// Creating new Lesson
        let newLesson = Lesson(lessonID: String(ID),
                               dayNumber: String(dayNumber),
                               groupID: sameLessonButInDifferentTime.groupID,
                               dayName: lessonDay,
                               lessonName: sameLessonButInDifferentTime.lessonName,
                               lessonFullName: sameLessonButInDifferentTime.lessonFullName,
                               lessonNumber: String(lessonNumber),
                               lessonRoom: sameLessonButInDifferentTime.lessonRoom,
                               lessonType: lessonType,
                               teacherName: sameLessonButInDifferentTime.teacherName,
                               lessonWeek: String(currentWeek),
                               timeStart: timeStart,
                               timeEnd: timeEnd,
                               rate: sameLessonButInDifferentTime.rate,
                               teachers: sameLessonButInDifferentTime.teachers,
                               rooms: sameLessonButInDifferentTime.rooms, groups: [])
        
        /// Appending to `lessons` which will used in updateCoreData(datum: lessons)
        lessons.append(newLesson)
        
        lessons = sortLessons(lessons: lessons)

        /// CREATING NEW sheduleViewController
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let window = appDelegate?.window else { return }
        
        guard let sheduleViewController : SheduleViewController = mainStoryboard.instantiateViewController(withIdentifier: "SheduleViewController") as? SheduleViewController else { return }
        
        Settings.shared.isTryToReloadTableView = true

        /// Updating Core Data
        updateCoreData(vc: sheduleViewController, datum: lessons)
        
        /// SHOW NEW sheduleViewController
        let mainTabBar : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as! UITabBarController
        
        self.dismiss(animated: true, completion: {
            window.rootViewController = mainTabBar
        })
        
    }
    
    
    // MARK: - server
    /// Functon which getting data from server
    func server() {
        guard let url = URL(string: "https://api.rozklad.org.ua/v2/groups/\(settings.groupID)/lessons") else { return }
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()

            do {
                guard let serverFULLDATA = try? decoder.decode(WelcomeLessons.self, from: data) else { return }
                let datum = serverFULLDATA.data
                
//                self.unicalLessons = []
                self.getUnicalLessons(lessons: datum)
                self.getUnicalIDs(lessons: datum)
                self.serverLessons = datum
                
                DispatchQueue.main.async {
                    self.lessonPickerView.reloadAllComponents()
                    self.dayPickerView.reloadAllComponents()
                    self.numberLessonPickerView.reloadAllComponents()

                }
            }
        }
        task.resume()
    }
    
    
    
}


// MARK: - Extension for Pickers
/// `lessonPickerView` ->  `lessonName` (component 0) + `lessonType` (component 1)
/// `dayPickerView` -> `dayName` (component 0)
/// `numberLessonPickerView` -> `Int` (component 0)
extension AddLessonViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    // MARK: - numberOfComponents
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == lessonPickerView {
            return 2
        }
        return 1
    }
    
    
    // MARK: - numberOfRowsInComponent
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == lessonPickerView {
            if component == 0 {
                return unicalLessons.count
            } else {
                /// lessonType
                return arrayTypePairs.count
            }
        } else if pickerView == dayPickerView {
            /// Monday -> Saturday
            return 6
        } else {
            /// lessonNumber
            return arrayPairs.count
        }
    }
    
    
    // MARK: - titleForRow
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == lessonPickerView {
            if component == 0 {
                let lesson = unicalLessons[row]
                return lesson.lessonName != "" ? lesson.lessonName : lesson.lessonFullName
           } else {
                if arrayTypePairs[row] == .empty {
                    return "Інше"
                }
            
                return arrayTypePairs[row].rawValue
           }
        } else if pickerView == dayPickerView {
            return getArrayOfDayNames()[row].rawValue
        } else {
            return arrayPairs[row]
        }
    }
    
    
    // MARK: - widthForComponent
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        /// `lessonName` has (3/4) of pickerView width and `lessonType` has (1/4) of pickerView width
        let w = pickerView.frame.size.width
        if pickerView == lessonPickerView {
            return component == 0 ? (3 / 4.0) * w : (1 / 4.0) * w
        }
        return w
    }
    
    
    // MARK: - didSelectRow
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == lessonPickerView {
            if component == 0 {
                lessonName = unicalNames[row]
                
                possibleTypeOfLessons(lessonNameToCheck: lessonName)

                lessonPickerView.reloadComponent(1)
                
           } else {
                lessonType = arrayTypePairs[row]
            }
           
        }
        
        if pickerView == dayPickerView {
            lessonDay = getArrayOfDayNames()[row]
            dayNumber = row + 1
            freeTimeInDay(dayNumber: dayNumber)
            numberLessonPickerView.reloadAllComponents()
        }
        
        if pickerView == numberLessonPickerView {
            lessonNumber = Int(String(arrayPairs[row][..<1])) ?? 1
        }
    }
    
}
