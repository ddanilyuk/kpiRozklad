//
//  NewLessonViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 17.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit
#if canImport(WidgetKit)
import WidgetKit
#endif

protocol NewLessonViewControllerDelegate {
    func newLessonAdded()
}

class NewLessonViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    /// Headers in table view
    let headersOfSections: [Int: String] = [
        0: "Введіть або оберіть з існуючих",
        3: "Оберіть тип пари",
        4: "Оберіть тиждень",
    ]
    
    /// Placeholders of `TextFieldNewLessonTableViewCell`
    let placeholdersOfSections: [Int: String] = [
        0: "Назва",
        1: "Викладач",
        2: "Аудиторія",
        5: "Оберіть день та пару"
    ]
    
    
    var lessons: [Lesson] = []
    
    var settings = Settings.shared
    
    var delegate: NewLessonViewControllerDelegate?
    
    
    var lessonName = String()
    
    var teacherName = String()

    var roomName = String()
    
    var dayName: DayName?
    
    var lessonNumber: Int = 0
    
    var lessonType: LessonType = .лек1
    
    var selectedWeek: WeekType = .first
    
    
    var isUnicalLessonsOpen: Bool = false
    
    var isUnicalTeachersOpen: Bool = false

    var isUnicalRoomsOpen: Bool = false
    
    var isDayNameAndPairOpen: Bool = false

    
    var unicalLessonNames: [String] = []
    
    var unicalTeacherNames: [String] = []
    
    var unicalRoomNames: [String] = []
    
    var unicalDataDayAndLessonNumber: [DayName: [Int]] = [:]

    
    var selectedRowInPickers: [Int: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        setupTableView()
        setupUnicalData()
    }
    
    private func setupUnicalData() {
        unicalLessonNames = getUnicalLessons()
        unicalTeacherNames = getUnicalTeachers()
        unicalRoomNames = getUnicalRooms()
        unicalDataDayAndLessonNumber = getDataForDayAndLessonNumberCell()
    }
    
    func getUnicalLessons() -> [String] {
        let lessonsSet = Set(lessons.map { $0.lessonFullName })
        return Array<String>(lessonsSet).sorted().filter { $0 != "" }
    }
    
    func getUnicalTeachers() -> [String] {
        let teachersSet = Set(lessons.map { $0.teacherName })
        return Array<String>(teachersSet).sorted().filter { $0 != "" }
    }
    
    func getUnicalRooms() -> [String] {
        let roomsSet = Set(lessons.map { $0.room?.roomName ?? "" })
        return Array<String>(roomsSet).sorted().filter { $0 != "" }
    }
    
    func getDataForDayAndLessonNumberCell() -> [DayName: [Int]] {
        var result: [DayName: [Int]] = [:]
        for day in DayName.allCases {
            var possiblePairs = [1, 2, 3, 4, 5, 6]
            
            lessons.forEach { lesson in
                if lesson.dayName == day && lesson.lessonWeek == selectedWeek {
                    possiblePairs.removeAll{ $0 == lesson.lessonNumber }
                }
            }
            result[day] = possiblePairs
        }
        return result
    }

    @IBAction func didPressAddLesson(_ sender: UIButton) {
        /// Creating new unical IDs for name, teacher and room
        var newUnicalLessonID = Int.random(in: 1..<9999)
        while lessons.contains(where: { $0.id == newUnicalLessonID }) {
            newUnicalLessonID = Int.random(in: 1..<9999)
        }
        
        
        var newUnicalRoomID = Int.random(in: 1..<9999)
        while lessons.contains(where: { $0.room?.roomID == newUnicalRoomID }) {
            newUnicalRoomID = Int.random(in: 1..<9999)
        }
        
        var newUnicalTeacherID = Int.random(in: 1..<9999)
        if unicalTeacherNames.contains(teacherName) {
            newUnicalTeacherID = lessons.first {$0.teacherName == teacherName }?.teacher?.teacherID ?? 0
        } else {
            while lessons.contains(where: { $0.teacher?.teacherID == newUnicalTeacherID }) {
                newUnicalTeacherID = Int.random(in: 1..<9999)
            }
        }
        
        var alertMessage = String()
        if lessonName == "" {
            alertMessage = "Будь ласка, оберіть назву пари"
        } else if dayName == nil || lessonNumber == 0 || lessonNumber > 6 {
            alertMessage = "Будь ласка, оберіть день та час"
        }
        
        if alertMessage != "" {
            let alert = UIAlertController(title: "Пару не додано", message: alertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Назад", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        if let dayName = dayName {
            let time = getTimeFromLessonNumber(lessonNumber: lessonNumber)
            
            let newLesson = Lesson(id: newUnicalLessonID,
                                   dayNumber: dayName.sortOrder,
                                   lessonNumber: lessonNumber,
                                   lessonWeek: selectedWeek,
                                   groupID: settings.groupID,
                                   dayName: dayName,
                                   lessonType: lessonType,
                                   lessonName: lessonName,
                                   lessonFullName: lessonName,
                                   lessonRoom: roomName,
                                   teacherName: teacherName,
                                   timeStart: time.timeStart.stringTime,
                                   timeEnd: time.timeEnd.stringTime,
                                   rate: "",
                                   teacher: Teacher(teacherID: newUnicalTeacherID,
                                                    teacherURL: "",
                                                    teacherName: teacherName,
                                                    teacherFullName: teacherName,
                                                    teacherShortName: teacherName,
                                                    teacherRating: "0.0"),
                                   room: Room(roomID: newUnicalRoomID,
                                              roomName: roomName,
                                              roomLatitude: "",
                                              roomLongitude: ""),
                                   groups: nil)
            lessons.append(newLesson)
            
            lessons = lessons.sorted()
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            guard let managedContext = appDelegate?.persistentContainer.viewContext else { return }

            updateCoreData(lessons: lessons, managedContext: managedContext) {
                if #available(iOS 14.0, *) {
                    reloadDataOnAppleWatch()
                    WidgetCenter.shared.reloadAllTimelines()
                }
                self.delegate?.newLessonAdded()
                self.closeViewController()
            }
        }
    }
    
    @IBAction func didPressCancel(_ sender: UIBarButtonItem) {
        closeViewController()
    }
    
    func closeViewController() {
        if #available(iOS 13.0, *) {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.backgroundColor = tint
        tableView.backgroundColor = tint

        /// Register  cells
        tableView.register(UINib(nibName: TextFieldAndButtonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: TextFieldAndButtonTableViewCell.identifier)
        tableView.register(UINib(nibName: LessonTypeAndWeekTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: LessonTypeAndWeekTableViewCell.identifier)
        tableView.register(UINib(nibName: DropDownPickerTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: DropDownPickerTableViewCell.identifier)
        tableView.register(UINib(nibName: LessonDayAndNumberTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: LessonDayAndNumberTableViewCell.identifier)
        }
}

extension NewLessonViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return isUnicalLessonsOpen ? 2 : 1
        } else if section == 1 {
            return isUnicalTeachersOpen ? 2 : 1
        } else if section == 2 {
            return isUnicalRoomsOpen ? 2 : 1
        } else if section == 5 {
            return isDayNameAndPairOpen ? 2 : 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 1 ? 150 : 45
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headersOfSections[section] == nil ? 20 : 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headersOfSections[section]
    }
    
    /**
     Creating cells for sections: 0, 1, 2, 5
     - Parameters:
        - section: In which section this cell must created.
        - unicalData: Array of strings for `dropDownCell`.
        - textCell: Put text in main cell.
        - isNeedToShowDetails: If `true` return two cells, if `false` return only main cell.
     - Returns:
        Array of cell for section. In array must be only one or two cells
     */
    func makeCellsForSection(at section: Int, with unicalData: [String], textCell: String, isNeedToShowDetails: Bool) -> [UITableViewCell] {
        var arrayWithCells: [UITableViewCell] = []
        
        guard let newLessonCell = tableView.dequeueReusableCell(withIdentifier: TextFieldAndButtonTableViewCell.identifier, for: IndexPath(row: 0, section: section)) as? TextFieldAndButtonTableViewCell else {
            assertionFailure("Cell not created")
            return []
        }
        newLessonCell.configureCell(text: textCell, placeholder: placeholdersOfSections[section])
        newLessonCell.indexPath = IndexPath(row: 0, section: section)
        newLessonCell.delegate = self
        newLessonCell.selectionStyle = .none
        arrayWithCells.append(newLessonCell)
        
        if isNeedToShowDetails {
            guard let cellWithOnePicker = tableView.dequeueReusableCell(withIdentifier: DropDownPickerTableViewCell.identifier, for: IndexPath(row: 1, section: section)) as? DropDownPickerTableViewCell else {
                assertionFailure("Cell not created")
                return []
            }
            cellWithOnePicker.fatherIndexPath = IndexPath(row: 0, section: section)
            cellWithOnePicker.dataArray = unicalData
            cellWithOnePicker.delegate = self
            cellWithOnePicker.previousSelectedIndex = selectedRowInPickers[section] ?? 0
            cellWithOnePicker.selectionStyle = .none
            arrayWithCells.append(cellWithOnePicker)
        }
        return arrayWithCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (0...2).contains(indexPath.section) {
            var cells: [UITableViewCell] = []
            if indexPath.section == 0 {
                cells = makeCellsForSection(at: 0, with: unicalLessonNames, textCell: lessonName, isNeedToShowDetails: isUnicalLessonsOpen)
            } else if indexPath.section == 1 {
                cells = makeCellsForSection(at: 1, with: unicalTeacherNames, textCell: teacherName, isNeedToShowDetails: isUnicalTeachersOpen)
            } else if indexPath.section == 2 {
                cells = makeCellsForSection(at: 2, with: unicalRoomNames, textCell: roomName, isNeedToShowDetails: isUnicalRoomsOpen)
            }
            return indexPath.row == 0 ? cells[0] : cells[1]
        } else if (3...4).contains(indexPath.section) {
            guard let lessonTypeCell = tableView.dequeueReusableCell(withIdentifier: LessonTypeAndWeekTableViewCell.identifier, for: indexPath) as? LessonTypeAndWeekTableViewCell else { return UITableViewCell() }
             
            lessonTypeCell.cellType = indexPath.section == 3 ? .lessonType : .week
            lessonTypeCell.selectedType = lessonType
            lessonTypeCell.selectedWeek = selectedWeek
            lessonTypeCell.delegate = self
            lessonTypeCell.selectionStyle = .none
            
            return lessonTypeCell
        } else if indexPath.section == 5 {
            if indexPath.row == 0 {
                guard let newLessonCell = tableView.dequeueReusableCell(withIdentifier: TextFieldAndButtonTableViewCell.identifier, for: indexPath) as? TextFieldAndButtonTableViewCell else { return UITableViewCell() }
                if let dayName = dayName {
                    newLessonCell.configureCell(text: "\(dayName.rawValue), \(lessonNumber) пара", placeholder: nil)
                } else {
                    newLessonCell.configureCell(placeholder: placeholdersOfSections[indexPath.section])
                }
                
                newLessonCell.indexPath = indexPath
                newLessonCell.delegate = self
                newLessonCell.selectionStyle = .none
                newLessonCell.mainTextField.isEnabled = false
                return newLessonCell
            } else {
                guard let lessonDayAndNumberCell = tableView.dequeueReusableCell(withIdentifier: LessonDayAndNumberTableViewCell.identifier, for: indexPath) as? LessonDayAndNumberTableViewCell else { return UITableViewCell() }
                lessonDayAndNumberCell.delegate = self
                
                if let dayName = dayName {
                    lessonDayAndNumberCell.configureCell(day: dayName, lessonNumber: lessonNumber)
                } else {
                    lessonDayAndNumberCell.data = unicalDataDayAndLessonNumber
                }
                return lessonDayAndNumberCell
            }
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "id")
            return cell
        }
    }
}


extension NewLessonViewController: TextFieldAndButtonTableViewCellDelegate {
    
    func userChangeTextInTextField(at indexPath: IndexPath, text: String) {
        if indexPath.section == 0 {
            lessonName = text
        } else if indexPath.section == 1 {
            teacherName = text
        } else if indexPath.section == 2 {
            roomName = text
        }
    }
    
    func userDidPressShowDetails(at indexPath: IndexPath) {

        var switcherValue = false
        
        if indexPath.section == 0 {
            isUnicalLessonsOpen.toggle()
            switcherValue = isUnicalLessonsOpen
        } else if indexPath.section == 1 {
            isUnicalTeachersOpen.toggle()
            switcherValue = isUnicalTeachersOpen
        } else if indexPath.section == 2 {
            isUnicalRoomsOpen.toggle()
            switcherValue = isUnicalRoomsOpen
        } else if indexPath.section == 5 {
            isDayNameAndPairOpen.toggle()
            switcherValue = isDayNameAndPairOpen
        } else {
            return
        }
        
        if switcherValue {
            tableView.insertRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
        } else {
            tableView.deleteRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
        }
    }
}


extension NewLessonViewController: DropDownPickerTableViewCellDelegate {
    
    func userChangedDropDownCellAt(fatherIndexPath: IndexPath, text: String, inPickerRow: Int) {
        if let cell = tableView.cellForRow(at: fatherIndexPath) as? TextFieldAndButtonTableViewCell {
            userChangeTextInTextField(at: fatherIndexPath, text: text)
            selectedRowInPickers[fatherIndexPath.section] = inPickerRow
            cell.configureCell(text: text, placeholder: nil)
        } else {
            userChangeTextInTextField(at: fatherIndexPath, text: text)
            selectedRowInPickers[fatherIndexPath.section] = inPickerRow
            return
        }
    }
}


extension NewLessonViewController: LessonDayAndNumberTableViewCellDelegate {
    
    func userSelectDayAndNumber(lessonDay: DayName, lessonNumber: Int) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 5)) as? TextFieldAndButtonTableViewCell else { return }
        self.dayName = lessonDay
        self.lessonNumber = lessonNumber
        cell.configureCell(text: "\(lessonDay.rawValue), \(lessonNumber) пара", placeholder: nil)
    }
}


extension NewLessonViewController: LessonTypeAndWeekTableViewCellDelegate {
    
    func userSelectweek(week: WeekType) {
        self.selectedWeek = week
        unicalDataDayAndLessonNumber = getDataForDayAndLessonNumberCell()
        guard let fatherCell = tableView.cellForRow(at: IndexPath(row: 0, section: 5)) as? TextFieldAndButtonTableViewCell else { return }
        guard let lessonDayAndNumberCell = tableView.cellForRow(at: IndexPath(row: 1, section: 5)) as? LessonDayAndNumberTableViewCell else {
            fatherCell.configureCell(placeholder: placeholdersOfSections[5])
            self.dayName = nil
            return
        }
        lessonDayAndNumberCell.data = unicalDataDayAndLessonNumber
    }
    
    func userSelectType(type: LessonType) {
        self.lessonType = type
    }
}
