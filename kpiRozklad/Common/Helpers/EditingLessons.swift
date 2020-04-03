//
//  EditingLessons.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 30.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit


func editLessonNumber(vc: SheduleViewController, indexPath: IndexPath) {
    var lessonsForCoreData = fetchingCoreData()
    
    lessonsForCoreData.removeAll { lesson -> Bool in
        var array: [String] = []
        for lesson in vc.lessonsForTableView[indexPath.section].value {
            array.append(lesson.lessonID)
        }
        return array.contains(lesson.lessonID)
    }
    
    /// Lesson which we want to edit
    let lesson = vc.lessonsForTableView[indexPath.section].value[indexPath.row]
    
    /// timeStart && timeEnd
    let (timeStart, timeEnd) = getTimeFromLessonNumber(lessonNumber: String(vc.lessonNumberFromPicker))
    let newLesson = Lesson( lessonID: lesson.lessonID,
                            dayNumber: lesson.dayNumber,
                            groupID: lesson.groupID,
                            dayName: lesson.dayName,
                            lessonName: lesson.lessonName,
                            lessonFullName: lesson.lessonFullName,
                            lessonNumber: String(vc.lessonNumberFromPicker),
                            lessonRoom: lesson.lessonRoom,
                            lessonType: lesson.lessonType,
                            teacherName: lesson.teacherName,
                            lessonWeek: lesson.lessonWeek,
                            timeStart: timeStart,
                            timeEnd: timeEnd,
                            rate: lesson.rate,
                            teachers: lesson.teachers,
                            rooms: lesson.rooms, groups: lesson.groups)
    
    vc.lessonsForTableView[indexPath.section].value.remove(at: indexPath.row)
    
    let dayLessons = vc.lessonsForTableView[indexPath.section].value
    
    var fullDayLessons: [Lesson?] = []
    
    for number in 1...6 {
        var lessonToAdd: Lesson?
        for lesson in dayLessons {
            if Int(lesson.lessonNumber) ?? 0 == number {
                lessonToAdd = lesson
            }
        }
        fullDayLessons.append(lessonToAdd)
    }

    var lessonTemp1: Lesson?
    var lessonTemp2: Lesson?

    lessonTemp2 = newLesson

    if Int(lesson.lessonNumber) ?? 0 < vc.lessonNumberFromPicker {
        /// Other pairs to left
        for i in stride(from: (vc.lessonNumberFromPicker - 1), to: (Int(lesson.lessonNumber) ?? 0) - 2, by: -1) {
            NASTYA_LYBIAMAYA(i: i, fullDayLessons: &fullDayLessons, lessonTemp1: &lessonTemp1, lessonTemp2: &lessonTemp2)
            if lessonTemp2 == nil {
                break
            }
        }
    } else {
        /// Other pairs to right
        for i in (vc.lessonNumberFromPicker - 1)...((Int(lesson.lessonNumber) ?? 0) - 1) {
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
    updateCoreData(vc: vc, datum: lessonsForCoreData)
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
    
    var lessonsForCoreData = fetchingCoreData()
    
    lessonsForCoreData.removeAll { lesson -> Bool in
        var array: [String] = []
        array.append(vc.lessonsForTableView[sourceIndexPath.section].value[sourceIndexPath.row].lessonID)
        for lesson in vc.lessonsForTableView[destinationIndexPath.section].value {
            array.append(lesson.lessonID)
        }
        return array.contains(lesson.lessonID)
    }

    let dayLessons = vc.lessonsForTableView[destinationIndexPath.section].value
    
    var fullDayLessons: [Lesson?] = []
    for number in 1...6 {
        var lessonToAdd: Lesson?
        for lesson in dayLessons {
            if Int(lesson.lessonNumber) ?? 0 == number {
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
        lessonNumber = Int(vc.lessonsForTableView[destinationIndexPath.section].value[destinationIndexPath.row - 1].lessonNumber) ?? 0
        lessonNumber += 1
        lessonNumber = lessonNumber > 6 ? 6 : lessonNumber
    }
    
    
    var dayNumber = 0

    switch vc.lessonsForTableView[destinationIndexPath.section].key {
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
    
    let oldLesson = vc.lessonsForTableView[sourceIndexPath.section].value[sourceIndexPath.row]
    
    let (timeStart, timeEnd) = getTimeFromLessonNumber(lessonNumber: String(lessonNumber))
    let newLesson = Lesson( lessonID: oldLesson.lessonID,
                            dayNumber: String(dayNumber),
                            groupID: oldLesson.groupID,
                            dayName: vc.lessonsForTableView[destinationIndexPath.section].key,
                            lessonName: oldLesson.lessonName,
                            lessonFullName: oldLesson.lessonFullName,
                            lessonNumber: String(lessonNumber),
                            lessonRoom: oldLesson.lessonRoom,
                            lessonType: oldLesson.lessonType,
                            teacherName: oldLesson.teacherName,
                            lessonWeek: oldLesson.lessonWeek,
                            timeStart: timeStart,
                            timeEnd: timeEnd,
                            rate: oldLesson.rate,
                            teachers: oldLesson.teachers,
                            rooms: oldLesson.rooms,
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
    updateCoreData(vc: vc, datum: lessonsForCoreData)
}


func NASTYA_LYBIAMAYA(i: Int, fullDayLessons: inout [Lesson?],  lessonTemp1: inout Lesson?, lessonTemp2: inout Lesson?) {
    lessonTemp1 = fullDayLessons[i]

    fullDayLessons.remove(at: i)

    let (timeStartEdited, timeEndEdited) = getTimeFromLessonNumber(lessonNumber: String(i + 1))
    guard let editedLessonTemp = lessonTemp2 else {
        fullDayLessons.insert(nil, at: i)
        return
    }
    let editedLesson = Lesson( lessonID: editedLessonTemp.lessonID,
                               dayNumber: editedLessonTemp.dayNumber,
                               groupID: editedLessonTemp.groupID,
                               dayName: editedLessonTemp.dayName,
                               lessonName: editedLessonTemp.lessonName,
                               lessonFullName: editedLessonTemp.lessonFullName,
                               lessonNumber: String(i + 1),
                               lessonRoom: editedLessonTemp.lessonRoom,
                               lessonType: editedLessonTemp.lessonType,
                               teacherName: editedLessonTemp.teacherName,
                               lessonWeek: editedLessonTemp.lessonWeek,
                               timeStart: timeStartEdited,
                               timeEnd: timeEndEdited,
                               rate: editedLessonTemp.rate,
                               teachers: editedLessonTemp.teachers,
                               rooms: editedLessonTemp.rooms,
                               groups: editedLessonTemp.groups)
    
    fullDayLessons.insert(editedLesson, at: i)

    lessonTemp2 = lessonTemp1
}
