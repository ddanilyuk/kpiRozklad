//
//  AddLessonViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 16.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

class AddLessonViewController: UIViewController {
    
    var lessons: [Lesson] = []
    var unicalLessons: [Lesson] = []
    var currentWeek: Int = 0

    
    var unicalIDs: [String] = []
    var unicalNames: [String] = []
    var unicalLessonsType: [LessonType] = []

    var lessonName: String = ""
    var lessonType: LessonType = LessonType.empty
    var lessonDay: DayName = DayName.mounday
    var lessonNumber: Int = 0
        
    @IBOutlet weak var lessonPickerView: UIPickerView!
    @IBOutlet weak var dayPickerView: UIPickerView!
    @IBOutlet weak var numberLessonPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        getUnicalLessons()

        lessonPickerView.delegate = self
        lessonPickerView.dataSource = self
        dayPickerView.delegate = self
        dayPickerView.dataSource = self
        numberLessonPickerView.delegate = self
        numberLessonPickerView.dataSource = self
        
        
        lessonPickerView.reloadAllComponents()
    }


    func getUnicalLessons() {
        for lesson in lessons {
            if !unicalNames.contains(lesson.lessonName){
                unicalLessons.append(lesson)
                getUnicalNames()
            }
        }
    }
    
    
    func getUnicalIDs() {
        unicalIDs = []
        for lesson in unicalLessons {
            unicalIDs.append(lesson.lessonID)
        }
    }
    
    func getUnicalNames() {
        unicalNames = []
        for lesson in unicalLessons {
            unicalNames.append(lesson.lessonName)
        }
    }
    
    func getUnicalLessonsType() {
        unicalLessonsType = []
        for lesson in unicalLessons {
            unicalLessonsType.append(lesson.lessonType)
        }
    }
    
    
    @IBAction func didPressAddLesson(_ sender: UIButton) {
        var similarLesson: Lesson?
        var isExist = false
        var isError = true
        
        for lesson in lessons {
            if lessonName == lesson.lessonName && lessonType == lesson.lessonType {
                similarLesson = lesson
                isError = false
                break
            }
        }
        
    
        for lesson in lessons {
            if String(currentWeek) == lesson.lessonWeek &&
            String(lessonNumber + 1) == lesson.lessonNumber &&
            lessonDay.rawValue == lesson.dayName.rawValue {
                isExist = true
            }
        }
        
        if isExist {
            let alert2 = UIAlertController(title: nil, message: "Цей час вже зайнятий", preferredStyle: .alert)

            alert2.addAction(UIAlertAction(title: "Вибрати інший час", style: .cancel, handler: nil))

            self.present(alert2, animated: true)
            return
        }
        
        if isError {
            var type = ""
            var message = ""
            var isEmptyLessonType = false
            
            switch lessonType {
            case .лаб:
                type = "лабораторних"
            case .лек:
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
        }
        
        
//        guard isExist else { return }
        
        guard let previousLesson = similarLesson else { return }
        
        
        
        var dayNumber = 0
        switch lessonDay {
            case .mounday:
                dayNumber = 1
            case .tuesday:
                dayNumber = 2
            case .wednesday:
                dayNumber = 3
            case .thursday:
                dayNumber = 4
            case .friday:
                dayNumber = 5
        }
        
        var timeStart = "00:00:00"
        var timeEnd = "00:00:00"
        
        switch lessonNumber {
        case 1:
            timeStart = "08:30:00"
            timeEnd = "10:05:00"
        case 2:
            timeStart = "10:25:00"
            timeEnd = "12:00:00"
        case 3:
            timeStart = "12:20:00"
            timeEnd = "13:55:00"
        case 4:
            timeStart = "14:15:00"
            timeEnd = "15:50:00"
        case 5:
            timeStart = "16:10:00"
            timeEnd = "17:45:00"
        default:
            timeStart = "00:00:00"
            timeEnd = "00:00:00"
        }
        
        var ID = Int.random(in: 0 ..< 9999)
        
        while unicalIDs.contains(String(ID)) {
            ID = Int.random(in: 0 ..< 9999)
        }
        
        let newLesson = Lesson(lessonID: String(ID),
                               groupID: previousLesson.groupID,
                               dayNumber: String(dayNumber),
                               dayName: lessonDay,
                               lessonName: previousLesson.lessonName,
                               lessonFullName: previousLesson.lessonFullName,
                               lessonNumber: String(lessonNumber),
                               lessonRoom: previousLesson.lessonRoom,
                               lessonType: lessonType,
                               teacherName: previousLesson.teacherName,
                               lessonWeek: String(currentWeek),
                               timeStart: timeStart,
                               timeEnd: timeEnd,
                               rate: previousLesson.rate,
                               teachers: previousLesson.teachers,
                               rooms: previousLesson.rooms)
        
        
        
        
        
        lessons.append(newLesson)

        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        
        let sheduleViewController : SheduleViewController = mainStoryboard.instantiateViewController(withIdentifier: "SheduleViewController") as! SheduleViewController
        sheduleViewController.updateCoreData(datum: lessons)
        
        Settings.shared.isTryToReloadTableView = true
        
        let mainVC : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as! UITabBarController
        guard let window = appDelegate?.window else { return }
        window.rootViewController = mainVC
        
    }
}

extension AddLessonViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == lessonPickerView {
            return 2
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == lessonPickerView {
            if component == 0 {
                return unicalLessons.count
            } else {
                return 4
            }
        } else if pickerView == dayPickerView {
            return 5
        } else {
            return 5
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == lessonPickerView {
            
            if component == 0 {
                let lesson = unicalLessons[row]
                return lesson.lessonFullName
           } else {
                let array = [LessonType.empty.rawValue, LessonType.лаб.rawValue, LessonType.лек.rawValue, LessonType.прак.rawValue]
                return array[row]
           }
        } else if pickerView == dayPickerView {
            let mounday = DayName.mounday
            let tuesday = DayName.tuesday
            let wednesday = DayName.wednesday
            let thursday = DayName.thursday
            let friday = DayName.friday
            
            let array = [mounday, tuesday, wednesday, thursday, friday]
            
            return array[row].rawValue
        } else {
            let array = ["1 пара", "2 пара", "3 пара", "4 пара", "5 пара"]
            return array[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let w = pickerView.frame.size.width
        if pickerView == lessonPickerView {
            return component == 0 ? (3 / 4.0) * w : (1 / 4.0) * w
        }
        return w
    }
    
    
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
                        lessonType = LessonType.лек
                    case 3:
                        lessonType = LessonType.прак
                    default:
                        lessonType = LessonType.empty
                }
            }
           
        }
        if pickerView == dayPickerView {
            let mounday = DayName.mounday
            let tuesday = DayName.tuesday
            let wednesday = DayName.wednesday
            let thursday = DayName.thursday
            let friday = DayName.friday
            
            let array = [mounday, tuesday, wednesday, thursday, friday]
                        lessonDay = array[row]
            
        }
        if pickerView == numberLessonPickerView{
            lessonNumber = row + 1
        }
        
        
    }
    
}
