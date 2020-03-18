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
        var array: [String] = [DayName.mounday.rawValue,
                               DayName.tuesday.rawValue,
                               DayName.wednesday.rawValue,
                               DayName.thursday.rawValue,
                               DayName.friday.rawValue,
                               DayName.saturday.rawValue]
        
        self.isEditing ? array.append("Нова пара") : nil
        
        returnedView.backgroundColor = sectionColour

        let label = UILabel(frame: CGRect(x: 16, y: 3, width: view.frame.size.width, height: 25))
        label.text = array[section]

        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            label.textColor = .black
        }
        returnedView.addSubview(label)

        return returnedView
    }
    
    // MARK: - titleForHeaderInSection
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var array: [String] = [DayName.mounday.rawValue,
                               DayName.tuesday.rawValue,
                               DayName.wednesday.rawValue,
                               DayName.thursday.rawValue,
                               DayName.friday.rawValue,
                               DayName.saturday.rawValue]
                        
        self.isEditing ? array.append("Нова пара") : nil
        return array[section]
    }
    
    
    // MARK: - numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isEditing == true && section == self.lessonsForTableView.count {
            return 1
        }
        else {
            return self.lessonsForTableView[section].value.count
        }
    }
    
    
    // MARK: - prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   
        if segue.identifier == "showDetailViewController" {
            if let strongDestinationLesson = destinationLesson {
                if let destination = segue.destination as? SheduleDetailViewController {
                    destination.lesson = strongDestinationLesson
                }
            } else {
                if let indexPath = tableView.indexPathForSelectedRow {
                    if let destination = segue.destination as? SheduleDetailViewController {
                        if indexPath.section != lessonsForTableView.count {
                            destination.lesson = lessonsForTableView[indexPath.section].value[indexPath.row]
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    // MARK: - didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == lessonsForTableView.count {
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
            
            alertView.addAction(UIAlertAction(title: "Змінити", style: .default, handler: { (_) in
                editLessonNumber(vc: self, indexPath: indexPath)
            }))
            
            alertView.addAction(UIAlertAction(title: "Назад", style: .cancel, handler: { (_) in
            }))

            present(alertView, animated: true, completion: nil)
        } else {
            if indexPath.section != lessonsForTableView.count {
                

                
                guard let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: SheduleDetailNavigationController.identifier) as? SheduleDetailNavigationController else {
                    return
                }
                
                vc.lesson = lessonsForTableView[indexPath.section].value[indexPath.row]
                
                
                presentPanModal(vc)
                
                
                
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    
    // MARK: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /// Creating cell for adding new lessson
        if indexPath.section == self.lessonsForTableView.count && self.isEditing == true {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "addCell")
            cell.textLabel?.text = "Додати пару"
            return cell
        }
        
        
        /// Creating main cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LessonTableViewCell.identifier, for: indexPath) as? LessonTableViewCell else { return UITableViewCell() }
        if #available(iOS 13.0, *) {
            cell.backgroundColor = .systemBackground
        } else {
            cell.backgroundColor = .white
        }
        let lesson = lessonsForTableView[indexPath.section].value[indexPath.row]
        
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
            
            setupCurrentLessonCell(cell: cell)
        }
        
        if nextLessonId == lesson.lessonID {
            setupNextLessonCell(cell: cell)
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
            
            updateCoreDataV2(vc: self, datum: lessons)
        
            self.lessonsForTableView[indexPath.section].value.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)

            
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
        if indexPath.section == self.lessonsForTableView.count {
            return false
        }
        else {
            return true
        }
    }
    
    
    // MARK: - editingStyleForRowAt
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section == self.lessonsForTableView.count {
            return .insert
        } else if isEditing {
            return .delete
        } else {
            return .none
        }
    }
    
    
    // MARK: - targetIndexPathForMoveFromRowAt sourceIndexPath toProposedIndexPath
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section >= self.lessonsForTableView.count {
            return sourceIndexPath
        }
        else {
            return proposedDestinationIndexPath
        }
    }
    
    
    // MARK: - setEditing
    /// Calls when editing starts
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            self.tableView.setEditing(true, animated: true)
            self.tableView.insertSections(IndexSet(integer: self.lessonsForTableView.count), with: .automatic)
        }
        else {
            self.tableView.setEditing(false, animated: true)
            self.tableView.deleteSections(IndexSet(integer: self.lessonsForTableView.count), with: .automatic)
        }
    }
}
