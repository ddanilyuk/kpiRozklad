//
//  SheduleVC+UITableView.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 18.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


extension SheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - numberOfSections
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isEditing == true {
            return 7
        } else {
            return 6
        }
    }

    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        
//        self.isEditing ? daysArray.append("Нова пара") : nil
        if daysArray[0] != "Нова пара" && self.isEditing {
            daysArray.insert("Нова пара", at: 0)
        }
//        self.isEditing ? daysArray.insert("Нова пара", at: 0) : nil

        
        returnedView.backgroundColor = sectionColour

        let label = UILabel(frame: CGRect(x: 16, y: 3, width: view.frame.size.width, height: 25))
        label.text = daysArray[section]

        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        returnedView.addSubview(label)

        return returnedView
    }
    
    
    // MARK: - numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isEditing == true && section == 0 {
            return 1
        } else if self.isEditing == true {
            return self.lessonsForTableView[section - 1].value.count
        } else {
            return self.lessonsForTableView[section].value.count
        }
    }
    
    
    // MARK: - heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    
    // MARK: - didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && isEditing {
            presentAddLesson()
        } else if isEditing {
            /// Presenting alert (popup) with pickerView
            let alertView = UIAlertController(
                               title: nil,
                               message: "\n\n\n\n\n\n",
                               preferredStyle: .actionSheet)

            let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth - 16, height: 140))
            
            pickerView.dataSource = self
            pickerView.delegate = self

            alertView.view.addSubview(pickerView)
            let newIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            alertView.addAction(UIAlertAction(title: "Змінити", style: .default, handler: { (_) in
                editLessonNumber(vc: self, indexPath: newIndexPath)
            }))
            
            alertView.addAction(UIAlertAction(title: "Назад", style: .cancel, handler: nil ))

            present(alertView, animated: true, completion: nil)
        } else {
            if indexPath.section != lessonsForTableView.count {

                guard let sheduleDetailNC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: SheduleDetailNavigationController.identifier) as? SheduleDetailNavigationController else { return }
                
                sheduleDetailNC.lesson = lessonsForTableView[indexPath.section].value[indexPath.row]
                
                presentPanModal(sheduleDetailNC)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    
    // MARK: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellBackgroundColor : UIColor = {
            if #available(iOS 13.0, *) {
                return .systemBackground
            } else {
                return .white
            }
        }()
        
        /// Creating cell for adding new lessson
        if indexPath.section == 0 && self.isEditing == true {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "addCell")
            cell.textLabel?.text = "Додати пару"
            cell.backgroundColor = cellBackgroundColor
            return cell
        }
        
        /// Creating main cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LessonTableViewCell.identifier, for: indexPath) as? LessonTableViewCell else { return UITableViewCell() }
        cell.backgroundColor = cellBackgroundColor
        let lesson = isEditing ? lessonsForTableView[indexPath.section - 1].value[indexPath.row] : lessonsForTableView[indexPath.section].value[indexPath.row]
        
        cell.lessonLabel.text = lesson.lessonName
        cell.teacherLabel.text = lesson.teacherName != "" ? lesson.teacherName : " "
        
        var colourTextLabel: UIColor {
            if #available(iOS 13.0, *) {
                return .label
            } else {
                return .black
            }
        }
        
        cell.startLabel.textColor = colourTextLabel
        cell.endLabel.textColor = colourTextLabel
        cell.teacherLabel.textColor = colourTextLabel
        cell.roomLabel.textColor = colourTextLabel
        cell.lessonLabel.textColor = colourTextLabel
        
        if currentLessonId == lesson.lessonID {
            setupCurrentOrNextLessonCell(cell: cell, cellType: .currentCell)
        }
        
        if nextLessonId == lesson.lessonID {
            setupCurrentOrNextLessonCell(cell: cell, cellType: .nextCell)
        }
        
        cell.startLabel.text = String(lesson.timeStart[..<5])
        cell.endLabel.text = String(lesson.timeEnd[..<5])
        cell.roomLabel.text = lesson.lessonType.rawValue + " " + lesson.lessonRoom
        cell.timeLeftLabel.text = ""
    
        return cell
    }

    
    // MARK: - commit editingStyle forRowAt
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            /// Lesson to delete
            let lesson = self.lessonsForTableView[indexPath.section].value[indexPath.row]
            
            var lessons = fetchingCoreDataV2()
            
            /// deleting from `lessons`  which will be used for further updates in `updateCoreData(datum: lessons)`
            for i in 0..<lessons.count {
                let lessonAll = lessons[i]
                if lessonAll.lessonID == lesson.lessonID {
                    lessons.remove(at: i)
                    break
                }
            }
            
            self.tableView.beginUpdates()
            self.lessonsForTableView[indexPath.section].value.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()

            // If delete DispatchQueue animation broken
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                updateCoreDataV2(vc: self, datum: lessons)
            }
            
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
        if isEditing {
            return indexPath.section == 0 ? false : true
        } else {
            return true
        }
    }
    
    
    // MARK: - editingStyleForRowAt
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        if indexPath.section == self.lessonsForTableView.count {
//            return .insert
//        } else if isEditing {
//            return .delete
//        } else {
//            return .none
//        }
        if indexPath.section == 0 && isEditing {
            return .insert
        } else if isEditing {
            return .delete
        } else {
            return .none
        }
    }
    
    
    // MARK: - targetIndexPathForMoveFromRowAt sourceIndexPath toProposedIndexPath
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath.section >= self.lessonsForTableView.count ? sourceIndexPath : proposedDestinationIndexPath
    }
    
    
    // MARK: - setEditing
    /// Calls when editing starts
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            self.tableView.setEditing(true, animated: true)
            self.tableView.insertSections(IndexSet(integer: 0), with: .automatic)
        } else {
            self.tableView.setEditing(false, animated: true)
            self.daysArray.remove(at: 0)
            self.tableView.deleteSections(IndexSet(integer: 0), with: .automatic)
        }
    }
}
