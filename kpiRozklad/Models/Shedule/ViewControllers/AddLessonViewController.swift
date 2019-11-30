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
    var dayNumber = 0

        
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
        getUnicalLessons()
        getUnicalIDs()

        lessonPickerView.delegate = self
        lessonPickerView.dataSource = self
        
        dayPickerView.delegate = self
        dayPickerView.dataSource = self
        
        numberLessonPickerView.delegate = self
        numberLessonPickerView.dataSource = self
        
    }

    
    // MARK: - getUnicalLessons
    func getUnicalLessons() {
        for lesson in lessons {
            if !unicalNames.contains(lesson.lessonName){
                unicalLessons.append(lesson)
                getUnicalNames()
            }
        }
        lessonName = unicalLessons[0].lessonName != "" ? unicalLessons[0].lessonName : unicalLessons[0].lessonFullName
    }
    
    
    // MARK: - getUnicalIDs
    func getUnicalIDs() {
        unicalIDs = []
        for lesson in unicalLessons {
            unicalIDs.append(lesson.lessonID)
        }
    }
    
    
    // MARK: - getUnicalNames
    func getUnicalNames() {
        unicalNames = []
        for lesson in unicalLessons {
            unicalNames.append(lesson.lessonName)
        }
    }
        
    
    // MARK: - didPressAddLesson
    @IBAction func didPressAddLesson(_ sender: UIButton) {
        /// Variable lesson which already exist (and use it)
        var similarLesson: Lesson?
        
        /// When time which user choose is busy  == true
        var isTimeIsBusy = false
        
        /// When similar lesson is not exist ==  true
        var isSimilarLessonNotExist = true
        
        /// Some groups have `"лек"` but default is `"Лек"` and we equate this
        let lessonType2 = lessonType == LessonType.лек1 ? LessonType.лек2 : nil
        
        /// Finding `lesson` which already exist (and use it)
        for lesson in lessons {
            if lessonName == lesson.lessonName && (lessonType == lesson.lessonType || lessonType2 == lesson.lessonType) {
                similarLesson = lesson
                isSimilarLessonNotExist = false
                break
            }
        }
        
        /// Checking time which user choose
        for lesson in lessons {
            if String(currentWeek) == lesson.lessonWeek &&
            String(lessonNumber) == lesson.lessonNumber &&
            lessonDay.rawValue == lesson.dayName.rawValue {
                isTimeIsBusy = true
            }
        }
        
        /// If `isTimeIsBusy` present appropriate alert
        if isTimeIsBusy {
            let alert = UIAlertController(title: nil, message: "Цей час вже зайнятий", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Вибрати інший час", style: .cancel, handler: nil))

            self.present(alert, animated: true)
            
            return
        }
        
        /// If `isSimilarLessonNotExist` present appropriate alert
        if isSimilarLessonNotExist {
            var type = ""
            var message = ""
            var isEmptyLessonType = false
            
            switch lessonType {
            case .лаб:
                type = "лабораторних"
            case .лек1:
                type = "лекцій"
            case .лек2:
                type = "лекцій"
            case .прак:
                type = "практик"
            case .empty:
                isEmptyLessonType = true
            }
            
            message = (isEmptyLessonType) ? "Виберіть тип пари" : "У вас в розкладі немає \(type) з \n \(lessonName)"
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Вибрати інший тип пари", style: .cancel, handler: nil))

            self.present(alert, animated: true)
            
            return
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
                return 4
            }
        } else if pickerView == dayPickerView {
            /// Monday -> Saturday
            return 6
        } else {
            /// lessonNumber
            return 6
        }
    }
    
    
    // MARK: - titleForRow
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == lessonPickerView {
            if component == 0 {
                let lesson = unicalLessons[row]
                return lesson.lessonName != "" ? lesson.lessonName : lesson.lessonFullName
           } else {
                let array = [LessonType.empty.rawValue, LessonType.лаб.rawValue, LessonType.лек1.rawValue, LessonType.прак.rawValue]
                return array[row]
           }
        } else if pickerView == dayPickerView {
            return getArrayOfDayNames()[row].rawValue
        } else {
            let array = ["1 пара", "2 пара", "3 пара", "4 пара", "5 пара", "6 пара"]
            return array[row]
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
           } else {
                switch row {
                case 0:
                    lessonType = LessonType.empty
                case 1:
                    lessonType = LessonType.лаб
                case 2:
                    lessonType = LessonType.лек1
                case 3:
                    lessonType = LessonType.прак
                default:
                    lessonType = LessonType.empty
                }
            }
           
        }
        
        if pickerView == dayPickerView {
            lessonDay = getArrayOfDayNames()[row]
            dayNumber = row + 1
        }
        
        if pickerView == numberLessonPickerView {
            lessonNumber = row + 1
        }
    }
    
}
