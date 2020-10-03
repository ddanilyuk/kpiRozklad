//
//  SheduleVC+UITableView.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 18.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

#if canImport(WidgetKit)
import WidgetKit
#endif

extension SheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isEditing ? 7 : 6
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 5))
        returnedView.backgroundColor = .green
        
        return returnedView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        returnedView.backgroundColor = sectionColour

        let label = UILabel(frame: CGRect(x: 16, y: 3, width: view.frame.size.width, height: 25))

        if daysArray[0] != "Нова пара" && self.isEditing {
            daysArray.insert("Нова пара", at: 0)
        }
        
        label.text = daysArray[section]

        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        returnedView.addSubview(label)
        return returnedView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isEditing == true && section == 0 {
            return 1
        } else if self.isEditing == true {
            return self.lessonsForTableView[section - 1].lessons.count
        } else {
            return self.lessonsForTableView[section].lessons.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing && indexPath.section == 0 {
            presentNewLesson()
        } else if isEditing {
            presentLessonNumberPicker(indexPath: indexPath)
        } else {
            if indexPath.section != lessonsForTableView.count {
                if isTeachersShedule {
                    let lesson = lessonsForTableView[indexPath.section].lessons[indexPath.row]
                    let groupsNames = lesson.getGroupsOfLessonInString()
                    
                    let alert = UIAlertController(title: nil, message: "Групи: \(groupsNames)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Назад", style: .cancel, handler: nil ))
                    
                    self.present(alert, animated: true, completion: nil)
                    tableView.deselectRow(at: indexPath, animated: true)
                } else {
                    guard let sheduleDetailNC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: SheduleDetailNavigationController.identifier) as? SheduleDetailNavigationController else { return }
                    
                    sheduleDetailNC.lesson = lessonsForTableView[indexPath.section].lessons[indexPath.row]
                    presentPanModal(sheduleDetailNC)
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if indexPath.section == 0 && self.isEditing == true {
            
            /// Creating cell for adding new lessson
            let cell = UITableViewCell(style: .default, reuseIdentifier: "addCell")
            cell.textLabel?.text = "Додати пару"
            cell.backgroundColor = cellBackgroundColor
            return cell
        } else {
            
            /// Creating main cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LessonTableViewCell.identifier, for: indexPath) as? LessonTableViewCell else { return UITableViewCell() }
            let lesson = isEditing ? lessonsForTableView[indexPath.section - 1].lessons[indexPath.row] : lessonsForTableView[indexPath.section].lessons[indexPath.row]
            if currentLessonId == lesson.id {
                cell.setupCell(with: lesson, type: .currentCell)
            } else if nextLessonId == lesson.id {
                cell.setupCell(with: lesson, type: .nextCell)
            } else {
                cell.setupCell(with: lesson, type: .defaultCell)
            }
            
            return cell
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let newIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            /// Lesson to delete
            let lesson = self.lessonsForTableView[newIndexPath.section].lessons[newIndexPath.row]
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext

            
            var lessons = fetchingCoreData(managedContext: managedContext)
            
            /// deleting from `lessons`  which will be used for further updates in `updateCoreData(datum: lessons)`
            for i in 0..<lessons.count {
                let lessonAll = lessons[i]
                if lessonAll.id == lesson.id {
                    lessons.remove(at: i)
                    break
                }
            }
            
            self.lessonsForTableView[newIndexPath.section].lessons.remove(at: newIndexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)

            // If delete DispatchQueue animation broken
            self.tableView.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
                updateCoreData(lessons: lessons, managedContext: managedContext) {
                    self.makeLessonsShedule()
                    reloadDataOnAppleWatch()
                    if #available(iOS 14.0, *) {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
                self.tableView.isUserInteractionEnabled = true
            }
            
        } else if editingStyle == .insert {
            presentNewLesson()
        }
    }
     
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let newSourceIndexPath = IndexPath(row: sourceIndexPath.row, section: sourceIndexPath.section - 1)
        let newdestinationIndexPath = IndexPath(row: destinationIndexPath.row, section: destinationIndexPath.section - 1)
        moveRow(vc: self, sourceIndexPath: newSourceIndexPath, destinationIndexPath: newdestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if isEditing {
            return indexPath.section == 0 ? false : true
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section == 0 && isEditing {
            return .insert
        } else if isEditing {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section > 0 {
            let dayLessonCount = lessonsForTableView[proposedDestinationIndexPath.section - 1].lessons.count
            
            /// If try to add 7 pair return `sourceIndexPath`
            return (dayLessonCount >= 6 && proposedDestinationIndexPath.section != sourceIndexPath.section) ? sourceIndexPath : proposedDestinationIndexPath
        }
        return sourceIndexPath
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            self.tableView.setEditing(true, animated: true)
            self.tableView.insertSections(IndexSet(integer: 0), with: .automatic)
        } else {
            self.tableView.setEditing(false, animated: true)
            if daysArray[0] == "Нова пара" {
                self.daysArray.remove(at: 0)
            }
            self.tableView.deleteSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    func presentLessonNumberPicker(indexPath: IndexPath) {
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
    }
    
}
