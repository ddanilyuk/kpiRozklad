//
//  EditingLessons.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 30.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit


// MARK: - editLessonNumber
/// Function calls when user vant to edit lesson number
/// - note: Next lesson automatically adjust
/// - Parameter indexPath: (indexPathFromPicker) Index Path from popup which edit number of lesson (tap on lesson while editing)
func editLessonNumber(vc: SheduleViewController, indexPath: IndexPath) {
    
    var lessons = fetchingCoreData()
    let lesson = vc.lessonsForTableView[indexPath.section].value[indexPath.row]
    
    /// timeStart && timeEnd
    let times = getTimeFromLessonNumber(lessonNumber: String(vc.lessonNuberFromPicker))
    let timeStart = times.timeStart
    let timeEnd = times.timeEnd

    let newLesson = Lesson(lessonID: lesson.lessonID,
                           dayNumber: lesson.dayNumber,
                           groupID: lesson.groupID,
                           dayName: lesson.dayName,
                           lessonName: lesson.lessonName,
                           lessonFullName: lesson.lessonFullName,
                           lessonNumber: String(vc.lessonNuberFromPicker),
                           lessonRoom: lesson.lessonRoom,
                           lessonType: lesson.lessonType,
                           teacherName: lesson.teacherName,
                           lessonWeek: lesson.lessonWeek,
                           timeStart: timeStart,
                           timeEnd: timeEnd,
                           rate: lesson.rate,
                           teachers: lesson.teachers,
                           rooms: lesson.rooms, groups: [])

    /// Deleting old
    vc.lessonsForTableView[indexPath.section].value.remove(at: indexPath.row)

    /// Inserting new
    vc.lessonsForTableView[indexPath.section].value.insert(newLesson, at: indexPath.row)

    /// deleting from `lessons`  which will be used for further updates in `updateCoreData(datum: lessons)`
    for i in 0..<lessons.count {
        let lessonAll = lessons[i]
        if lessonAll.lessonID == lesson.lessonID {
            lessons.remove(at: i)
            break
        }
    }

    /// Appending new to `lessons`
    lessons.append(newLesson)
    
    /// Lessons  in which time will change
    var lessonsToEdit: [Lesson] = []
    
    /// Getting lessons from `.section` (day)
    let lessonForSection = vc.lessonsForTableView[indexPath.section].value
    
    /// Creating iterator
    var iterator = lessonForSection.makeIterator()
    
    /// It is added if the next lesson will change
    var i = 0

    /// iterating
    while let nLesson = iterator.next() {
        let nLessonNumber = Int(nLesson.lessonNumber) ?? 0

        if nLessonNumber <= vc.lessonNuberFromPicker + i && nLessonNumber + i >= vc.lessonNuberFromPicker  && nLesson.lessonID != newLesson.lessonID {
            lessonsToEdit.append(nLesson)
            i += 1
        }
        
    }
    
    /// Modified lessons with a shifted schedule are created and old ones are deleted
    for lesson in lessonsToEdit {
        
        var lessonNumberIntEdited: Int = Int(lesson.lessonNumber) ?? 0
        lessonNumberIntEdited += 1
        let lessonNumberEdited = String(lessonNumberIntEdited)
        
        let timesEdited = getTimeFromLessonNumber(lessonNumber: lessonNumberEdited)
        let timeStartEdited = timesEdited.timeStart
        let timeEndEdited = timesEdited.timeEnd
        
        let editedLesson = Lesson( lessonID: lesson.lessonID,
                                   dayNumber: lesson.dayNumber,
                                   groupID: lesson.groupID,
                                   dayName: lesson.dayName,
                                   lessonName: lesson.lessonName,
                                   lessonFullName: lesson.lessonFullName,
                                   lessonNumber: lessonNumberEdited,
                                   lessonRoom: lesson.lessonRoom,
                                   lessonType: lesson.lessonType,
                                   teacherName: lesson.teacherName,
                                   lessonWeek: lesson.lessonWeek,
                                   timeStart: timeStartEdited,
                                   timeEnd: timeEndEdited,
                                   rate: lesson.rate,
                                   teachers: lesson.teachers,
                                   rooms: lesson.rooms, groups: [])
        
        lessons.removeAll { lesson -> Bool in
            return lesson.lessonID == editedLesson.lessonID
        }
        lessons.append(editedLesson)

    }
    
    lessons = sortLessons(lessons: lessons)

    /// updateCoreData with edited variable `lessons`
    updateCoreData(vc: vc, datum: lessons)
    vc.tableView.reloadData()
}


func moveRow(vc: SheduleViewController, sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
    /// getting all lessons (this variable will refresh coreData)
    var lessons: [Lesson] = fetchingCoreData()
    
    /// lesson which we moved
    let lesson: Lesson = vc.lessonsForTableView[sourceIndexPath.section].value[sourceIndexPath.row]

    
    /// dayName && dayNumber
    var dayName: DayName
    var dayNumber = 0
    
    switch vc.lessonsForTableView[destinationIndexPath.section].key {
    case .mounday:
        dayName = .mounday
        dayNumber = 1
    case .tuesday:
        dayName = .tuesday
        dayNumber = 2
    case .wednesday:
        dayName = .wednesday
        dayNumber = 3
    case .thursday:
        dayName = .thursday
        dayNumber = 4
    case .friday:
        dayName = .friday
        dayNumber = 5
    case .saturday:
        dayName = .saturday
        dayNumber = 6
    }
    
    /// lessonNumber
    var lessonNumber = ""
    if destinationIndexPath.row == 0 {
       lessonNumber = "1"
    } else if destinationIndexPath.section == sourceIndexPath.section &&
              destinationIndexPath.row > sourceIndexPath.row {
        lessonNumber = String(vc.lessonsForTableView[destinationIndexPath.section].value[destinationIndexPath.row].lessonNumber)
        
        var lessonNumberInt: Int = Int(lessonNumber) ?? 0
        lessonNumberInt += 1
        lessonNumber = String(lessonNumberInt)
        
    } else {
        lessonNumber = String(vc.lessonsForTableView[destinationIndexPath.section].value[destinationIndexPath.row - 1].lessonNumber)
        
        var lessonNumberInt: Int = Int(lessonNumber) ?? 0
        lessonNumberInt += 1
        lessonNumber = String(lessonNumberInt)
    }
     
    /// timeStart && timeEnd
    let times = getTimeFromLessonNumber(lessonNumber: lessonNumber)
    let timeStart = times.timeStart
    let timeEnd = times.timeEnd

    let newLesson = Lesson(lessonID: lesson.lessonID,
                           dayNumber: String(dayNumber),
                           groupID: lesson.groupID,
                           dayName: dayName,
                           lessonName: lesson.lessonName,
                           lessonFullName: lesson.lessonFullName,
                           lessonNumber: String(lessonNumber),
                           lessonRoom: lesson.lessonRoom,
                           lessonType: lesson.lessonType,
                           teacherName: lesson.teacherName,
                           lessonWeek: lesson.lessonWeek,
                           timeStart: timeStart,
                           timeEnd: timeEnd,
                           rate: lesson.rate,
                           teachers: lesson.teachers,
                           rooms: lesson.rooms, groups: [])

    vc.lessonsForTableView[sourceIndexPath.section].value.remove(at: sourceIndexPath.row)

    vc.lessonsForTableView[destinationIndexPath.section].value.insert(newLesson, at: destinationIndexPath.row)

    for i in 0..<lessons.count {
        let lessonAll = lessons[i]
        if lessonAll.lessonID == lesson.lessonID {
            lessons.remove(at: i)
            lessons.insert(newLesson, at: i)
            break
        }
    }


    if newLesson.lessonNumber == lesson.lessonNumber && newLesson.dayNumber == lesson.dayNumber {
        return
    }
    
    /// editing lessons
    var lessonsToEdit: [Lesson] = []
    
    var nextLesson: Lesson?
    
//             TODO:- USE ITERATOR

//            let lessonForSection = self.lessonsForTableView[destinationIndexPath.section].value
//            var iterator = lessonForSection.makeIterator()
//            var i = 0
//            while let nLesson = iterator.next() {
//                if Int(nLesson.lessonNumber) ?? 0 + i > destinationIndexPath.row + 1 && nLesson.lessonID != newLesson.lessonID{
//                    i += 1
//                    lessonsToEdit.append(nLesson)
//                }
//            }
    
    
    if vc.lessonsForTableView[destinationIndexPath.section].value.count > destinationIndexPath.row + 1 {
        nextLesson = vc.lessonsForTableView[destinationIndexPath.section].value[destinationIndexPath.row + 1]
    }

    var k = 0
    var i = 2

    if let nextLessonG = nextLesson {
        var next = nextLessonG
        var nextLessonNumber = Int(next.lessonNumber) ?? 0
        let currentLessonNumber = Int(lessonNumber) ?? 0


        for _ in 0..<10 {
            if currentLessonNumber + k >= nextLessonNumber {
                k += 1
                lessonsToEdit.append(next)
                if vc.lessonsForTableView[destinationIndexPath.section].value.count > destinationIndexPath.row + i {
                    next = vc.lessonsForTableView[destinationIndexPath.section].value[destinationIndexPath.row + i]
                    nextLessonNumber = Int(next.lessonNumber) ?? 0
                } else {
                    break
                }
                i += 1
            }
        }
    }
    
    /// Modified lessons with a shifted schedule are created and old ones are deleted
    for lesson in lessonsToEdit {
        
        var lessonNumberIntEdited: Int = Int(lesson.lessonNumber) ?? 0
        lessonNumberIntEdited += 1
        let lessonNumberEdited = String(lessonNumberIntEdited)
        
        let timesEdited = getTimeFromLessonNumber(lessonNumber: lessonNumberEdited)
        let timeStartEdited = timesEdited.timeStart
        let timeEndEdited = timesEdited.timeEnd
        
        let editedLesson = Lesson( lessonID: lesson.lessonID,
                                   dayNumber: lesson.dayNumber,
                                   groupID: lesson.groupID,
                                   dayName: lesson.dayName,
                                   lessonName: lesson.lessonName,
                                   lessonFullName: lesson.lessonFullName,
                                   lessonNumber: lessonNumberEdited,
                                   lessonRoom: lesson.lessonRoom,
                                   lessonType: lesson.lessonType,
                                   teacherName: lesson.teacherName,
                                   lessonWeek: lesson.lessonWeek,
                                   timeStart: timeStartEdited,
                                   timeEnd: timeEndEdited,
                                   rate: lesson.rate,
                                   teachers: lesson.teachers,
                                   rooms: lesson.rooms, groups: [])
        
        lessons.removeAll { lesson -> Bool in
            return lesson.lessonID == editedLesson.lessonID
        }

        lessons.append(editedLesson)
    }
    
    lessons = sortLessons(lessons: lessons)

    updateCoreData(vc: vc, datum: lessons)
    vc.tableView.reloadData()
}
