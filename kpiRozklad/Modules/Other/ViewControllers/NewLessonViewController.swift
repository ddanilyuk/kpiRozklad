//
//  NewLessonViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 17.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

class NewLessonViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let headersOfSections: [Int: String] = [
        3: "Оберіть тип пари",
        4: "Оберіть тиждень",
        5: "Оберіть день та пару"
    ]
    
    let placeholdersOfSections: [Int: String] = [
        0: "Назва",
        1: "Викладач",
        2: "Аудиторія",
        5: "День"
    ]
    
    var lessons: [Lesson] = []
    
    
    var lessonName = String()
    
    var teacherName = String()

    var roomName = String()
    
    
    var isUnicalLessonsOpen: Bool = false
    
    var isUnicalTeachersOpen: Bool = false

    var isUnicalRoomsOpen: Bool = false

    
    var unicalLessonNames: [String] = []
    
    var unicalTeacherNames: [String] = []
    
    var unicalRoomNames: [String] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        setupTableView()
        getUnicalLessons()
        getUnicalTeachers()
        getUnicalRooms()
    }
    
    func getUnicalLessons() {
        let lessonsSet = Set(lessons.map { $0.lessonFullName })
        unicalLessonNames = Array<String>(lessonsSet).sorted().filter { $0 != "" }
    }
    
    func getUnicalTeachers() {
        let teachersSet = Set(lessons.map { $0.teacherName })
        unicalTeacherNames = Array<String>(teachersSet).sorted().filter { $0 != "" }
    }
    
    func getUnicalRooms() {
        let roomsSet = Set(lessons.map { $0.room?.roomName ?? "" })
        unicalRoomNames = Array<String>(roomsSet).sorted().filter { $0 != "" }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        self.view.backgroundColor = tint
        tableView.backgroundColor = tint

        /// Register  cells
        tableView.register(UINib(nibName: TextFieldNewLessonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: TextFieldNewLessonTableViewCell.identifier)
        tableView.register(UINib(nibName: LessonTypeAndWeekTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: LessonTypeAndWeekTableViewCell.identifier)
        tableView.register(UINib(nibName: CellWithOneSectionPickerTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: CellWithOneSectionPickerTableViewCell.identifier)
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
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 1 ? 150 : 45
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 4
        }
        return headersOfSections[section] == nil ? 20 : 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headersOfSections[section]
    }
    
    
    func makeCellsForSection(at section: Int, with unicalData: [String], textCell: String, isNeedToShowDetails: Bool) -> [UITableViewCell] {
        var arrayWithCells: [UITableViewCell] = []
        
        guard let newLessonCell = tableView.dequeueReusableCell(withIdentifier: TextFieldNewLessonTableViewCell.identifier, for: IndexPath(row: 0, section: section)) as? TextFieldNewLessonTableViewCell else {
            assertionFailure("Cell not created")
            return []
        }
        newLessonCell.configureCell(text: textCell, placeholder: placeholdersOfSections[section])
        newLessonCell.indexPath = IndexPath(row: 0, section: section)
        newLessonCell.delegate = self
        newLessonCell.selectionStyle = .none
        arrayWithCells.append(newLessonCell)
        
        if isNeedToShowDetails {
            guard let cellWithOnePicker = tableView.dequeueReusableCell(withIdentifier: CellWithOneSectionPickerTableViewCell.identifier, for: IndexPath(row: 1, section: section)) as? CellWithOneSectionPickerTableViewCell else {
                assertionFailure("Cell not created")
                return []
            }
            cellWithOnePicker.fatherIndexPath = IndexPath(row: 0, section: section)
            cellWithOnePicker.dataArray = unicalData
            cellWithOnePicker.delegate = self
            cellWithOnePicker.selectionStyle = .none
            arrayWithCells.append(cellWithOnePicker)
        }
        
        
        return arrayWithCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cells = makeCellsForSection(at: 0, with: unicalLessonNames, textCell: lessonName, isNeedToShowDetails: isUnicalLessonsOpen)
            if indexPath.row == 0 {
                return cells[0]
            } else {
                return cells[1]
            }
        case 1:
            let cells = makeCellsForSection(at: 1, with: unicalTeacherNames, textCell: teacherName, isNeedToShowDetails: isUnicalTeachersOpen)
            if indexPath.row == 0 {
                return cells[0]
            } else {
                return cells[1]
            }
        case 2:
            let cells = makeCellsForSection(at: 2, with: unicalRoomNames, textCell: roomName, isNeedToShowDetails: isUnicalRoomsOpen)
            if indexPath.row == 0 {
                return cells[0]
            } else {
                return cells[1]
            }
        case 3, 4:
            guard let lessonTypeCell = tableView.dequeueReusableCell(withIdentifier: LessonTypeAndWeekTableViewCell.identifier, for: indexPath) as? LessonTypeAndWeekTableViewCell else { return UITableViewCell() }
            if indexPath.section == 3 {
                lessonTypeCell.cellType = .lessonType
            } else if indexPath.section == 4 {
                lessonTypeCell.cellType = .week
            }
            lessonTypeCell.selectionStyle = .none
            return lessonTypeCell
        
        case 5:
            // TODO: - new cell
            let cell = UITableViewCell(style: .default, reuseIdentifier: "")
            return cell
        
        default:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "")
            return cell
        }
    }
    
    
}

extension NewLessonViewController: TextFieldNewLessonTableViewCellDelegate {
    func userTappedShowDetails(on cell: TextFieldNewLessonTableViewCell, at indexPath: IndexPath) {
        
        
//        if (0...2).contains(indexPath.section) {
//            if 
//        }
        
        if indexPath.section == 0 {
            if !isUnicalLessonsOpen {
                isUnicalLessonsOpen.toggle()
                tableView.insertRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
            } else {
                isUnicalLessonsOpen.toggle()
                tableView.deleteRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
            }
        } else if indexPath.section == 1 {
            if !isUnicalTeachersOpen {
                isUnicalTeachersOpen.toggle()
                tableView.insertRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
            } else {
                isUnicalTeachersOpen.toggle()
                tableView.deleteRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
            }
        } else if indexPath.section == 2 {
            if !isUnicalRoomsOpen {
                isUnicalRoomsOpen.toggle()
                tableView.insertRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
            } else {
                isUnicalRoomsOpen.toggle()
                tableView.deleteRows(at: [IndexPath(row: 1, section: indexPath.section)], with: .fade)
            }
        }
    }
}


extension NewLessonViewController: CellWithOneSectionPickerTableViewCellDelegate {
    func pickerCellUpdate(with Picker: UIPickerView, atFatherIndexPath indexPath: IndexPath, text: String) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TextFieldNewLessonTableViewCell else {
            assertionFailure("Invalid indexPath")
            return
        }
        if indexPath.section == 0 {
            lessonName = text
        } else if indexPath.section == 1 {
            teacherName = text
        } else if indexPath.section == 2 {
            roomName = text
        }

        cell.configureCell(text: text, placeholder: nil)
    }
    
    
}
