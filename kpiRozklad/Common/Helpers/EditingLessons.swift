//
//  EditingLessons.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 30.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit
import WidgetKit

func editLessonNumber(vc: SheduleViewController, indexPath: IndexPath) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    var lessonsForCoreData = fetchingCoreData(managedContext: managedContext)
    
    lessonsForCoreData.removeAll { lesson -> Bool in
        var array: [Int] = []
        for lesson in vc.lessonsForTableView[indexPath.section].lessons {
            array.append(lesson.id)
        }
        return array.contains(lesson.id)
    }
    
    /// Lesson which we want to edit
    let lesson = vc.lessonsForTableView[indexPath.section].lessons[indexPath.row]
    
    /// timeStart && timeEnd
    let (timeStart, timeEnd) = getTimeFromLessonNumber(lessonNumber: String(vc.lessonNumberFromPicker))
    
    let newLesson = Lesson(id: lesson.id,
                           dayNumber: lesson.dayNumber,
                           lessonNumber: vc.lessonNumberFromPicker,
                           lessonWeek: lesson.lessonWeek,
                           groupID: lesson.groupID,
                           dayName: lesson.dayName,
                           lessonType: lesson.lessonType,
                           lessonName: lesson.lessonName,
                           lessonFullName: lesson.lessonFullName,
                           lessonRoom: lesson.lessonRoom,
                           teacherName: lesson.teacherName,
                           timeStart: timeStart,
                           timeEnd: timeEnd,
                           rate: lesson.rate,
                           teacher: lesson.teacher,
                           room: lesson.room,
                           groups: lesson.groups)
    
    vc.lessonsForTableView[indexPath.section].lessons.remove(at: indexPath.row)
    
    let dayLessons = vc.lessonsForTableView[indexPath.section].lessons
    
    var fullDayLessons: [Lesson?] = []
    
    for number in 1...6 {
        var lessonToAdd: Lesson?
        for lesson in dayLessons {
            if lesson.lessonNumber == number {
                lessonToAdd = lesson
            }
        }
        fullDayLessons.append(lessonToAdd)
    }

    var lessonTemp1: Lesson?
    var lessonTemp2: Lesson?

    lessonTemp2 = newLesson

    if lesson.lessonNumber < vc.lessonNumberFromPicker {
        /// Other pairs to left
        for i in stride(from: (vc.lessonNumberFromPicker - 1), to: (lesson.lessonNumber - 2), by: -1) {
            NASTYA_LYBIAMAYA(i: i, fullDayLessons: &fullDayLessons, lessonTemp1: &lessonTemp1, lessonTemp2: &lessonTemp2)
            if lessonTemp2 == nil {
                break
            }
        }
    } else {
        /// Other pairs to right
        for i in (vc.lessonNumberFromPicker - 1)...((lesson.lessonNumber) - 1) {
            NASTYA_LYBIAMAYA(i: i, fullDayLessons: &fullDayLessons, lessonTemp1: &lessonTemp1, lessonTemp2: &lessonTemp2)

            lessonTemp2 = lessonTemp1
            if lessonTemp2 == nil {
                break
            }
        }
    }
        
    for lesson in fullDayLessons {
        if let lessonToAdd = lesson {
            lessonsForCoreData.append(lessonToAdd)
        }
        print(lesson?.lessonName ?? "Пусто", lesson?.lessonNumber ?? "---")
    }
    
    lessonsForCoreData = sortLessons(lessons: lessonsForCoreData)
    
    /// updateCoreData with edited variable `lessons`
    updateCoreData(lessons: lessonsForCoreData, managedContext: managedContext) {
        vc.makeLessonsShedule()
        WidgetCenter.shared.reloadAllTimelines()
    }
    vc.lessonNumberFromPicker = 1
}


func moveRow3(vc: SheduleViewController, sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
    if sourceIndexPath == destinationIndexPath {
        return
    } else if sourceIndexPath.section == destinationIndexPath.section {
        vc.lessonNumberFromPicker = destinationIndexPath.row + 1
        editLessonNumber(vc: vc, indexPath: sourceIndexPath)
        return
    }
    
    var lessonTemp1: Lesson?
    var lessonTemp2: Lesson?
    
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    var lessonsForCoreData = fetchingCoreData(managedContext: managedContext)
    
    lessonsForCoreData.removeAll { lesson -> Bool in
        var array: [Int] = []
        array.append(vc.lessonsForTableView[sourceIndexPath.section].lessons[sourceIndexPath.row].id)
        for lesson in vc.lessonsForTableView[destinationIndexPath.section].lessons {
            array.append(lesson.id)
        }
        return array.contains(lesson.id)
    }

    let dayLessons = vc.lessonsForTableView[destinationIndexPath.section].lessons
    
    var fullDayLessons: [Lesson?] = []
    for number in 1...6 {
        var lessonToAdd: Lesson?
        for lesson in dayLessons {
            if lesson.lessonNumber == number {
                lessonToAdd = lesson
            }
        }
        fullDayLessons.append(lessonToAdd)
    }
    
    var hole = 0
    for i in stride(from: 5, to: -1, by: -1) {
        let lesson = fullDayLessons[i]
        if lesson == nil {
            hole = i
            break
        }
    }
    
    var lessonNumber = 1
    if destinationIndexPath.row == 0 {
        lessonNumber = 1
    }

    if destinationIndexPath.row != 0 {
        lessonNumber = vc.lessonsForTableView[destinationIndexPath.section].lessons[destinationIndexPath.row - 1].lessonNumber
        lessonNumber += 1
        lessonNumber = lessonNumber > 6 ? 6 : lessonNumber
    }
    
    
    var dayNumber = 0

    switch vc.lessonsForTableView[destinationIndexPath.section].day {
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
    case .saturday:
        dayNumber = 6
    }
    
    let oldLesson = vc.lessonsForTableView[sourceIndexPath.section].lessons[sourceIndexPath.row]
    
    let (timeStart, timeEnd) = getTimeFromLessonNumber(lessonNumber: String(lessonNumber))
    
    let newLesson = Lesson(id: oldLesson.id,
                      dayNumber: dayNumber,
                      lessonNumber: lessonNumber,
                      lessonWeek: oldLesson.lessonWeek,
                      groupID: oldLesson.groupID,
                      dayName: vc.lessonsForTableView[destinationIndexPath.section].day,
                      lessonType: oldLesson.lessonType,
                      lessonName: oldLesson.lessonName,
                      lessonFullName: oldLesson.lessonFullName,
                      lessonRoom: oldLesson.lessonRoom,
                      teacherName: oldLesson.teacherName,
                      timeStart: timeStart,
                      timeEnd: timeEnd,
                      rate: oldLesson.rate,
                      teacher: oldLesson.teacher,
                      room: oldLesson.room,
                      groups: oldLesson.groups)
    
    lessonTemp2 = newLesson
    
    if hole < lessonNumber {
        /// Other pairs to left
        for i in stride(from: lessonNumber - 1, to: hole-1, by: -1) {
            NASTYA_LYBIAMAYA(i: i, fullDayLessons: &fullDayLessons, lessonTemp1: &lessonTemp1, lessonTemp2: &lessonTemp2)
            if lessonTemp2 == nil {
                break
            }
        }
    } else {
        /// Other pairs to right
        for i in (lessonNumber - 1)...(hole) {
            NASTYA_LYBIAMAYA(i: i, fullDayLessons: &fullDayLessons, lessonTemp1: &lessonTemp1, lessonTemp2: &lessonTemp2)

            lessonTemp2 = lessonTemp1
            if lessonTemp2 == nil {
                break
            }
        }
    }
    
    for lesson in fullDayLessons {
        if let lessonToAdd = lesson {
            lessonsForCoreData.append(lessonToAdd)
        }
    }
    
    lessonsForCoreData = sortLessons(lessons: lessonsForCoreData)

    /// updateCoreData with edited variable `lessons`
    updateCoreData(lessons: lessonsForCoreData, managedContext: managedContext) {
        vc.makeLessonsShedule()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
}


func NASTYA_LYBIAMAYA(i: Int, fullDayLessons: inout [Lesson?],  lessonTemp1: inout Lesson?, lessonTemp2: inout Lesson?) {
    lessonTemp1 = fullDayLessons[i]

    fullDayLessons.remove(at: i)

    let (timeStartEdited, timeEndEdited) = getTimeFromLessonNumber(lessonNumber: String(i + 1))
    guard let editedLessonTemp = lessonTemp2 else {
        fullDayLessons.insert(nil, at: i)
        return
    }

    let editedLesson = Lesson(id: editedLessonTemp.id,
                              dayNumber: editedLessonTemp.dayNumber,
                              lessonNumber: i + 1,
                              lessonWeek: editedLessonTemp.lessonWeek,
                              groupID: editedLessonTemp.groupID,
                              dayName: editedLessonTemp.dayName,
                              lessonType: editedLessonTemp.lessonType,
                              lessonName: editedLessonTemp.lessonName,
                              lessonFullName: editedLessonTemp.lessonFullName,
                              lessonRoom: editedLessonTemp.lessonRoom,
                              teacherName: editedLessonTemp.teacherName,
                              timeStart: timeStartEdited,
                              timeEnd: timeEndEdited,
                              rate: editedLessonTemp.rate,
                              teacher: editedLessonTemp.teacher,
                              room: editedLessonTemp.room,
                              groups: editedLessonTemp.groups)
    
    fullDayLessons.insert(editedLesson, at: i)

    lessonTemp2 = lessonTemp1
}
