//
//  ManagingLessons.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 30.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit


// MARK: - getCurrentAndNextLesson
/// Function that makes current lesson **orange** and next lesson **blue**
func getCurrentAndNextLesson(lessons: [Lesson],
                             timeIsNowString: String,
                             dayNumberFromCurrentDate: Int,
                             currentWeekFromTodayDate: Int) -> (nextLessonID: String, currentLessonID: String) {
    

    
    var nextLessonId = String()
    var currentLessonId = String()
    
    for lesson in lessons {
        
        let timeStart = String(lesson.timeStart[..<5])
        let timeEnd = String(lesson.timeEnd[..<5])
                    
        if  (timeStart <= timeIsNowString) && (timeIsNowString < timeEnd) &&
            (dayNumberFromCurrentDate == Int(lesson.dayNumber)) && (currentWeekFromTodayDate == Int(lesson.lessonWeek) ?? 0) {
            currentLessonId = lesson.lessonID
        }
        
        if (timeStart > timeIsNowString) && (dayNumberFromCurrentDate == Int(lesson.dayNumber) ?? 0) && (currentWeekFromTodayDate == Int(lesson.lessonWeek) ?? 0) {
            nextLessonId = lesson.lessonID
            return (nextLessonID: nextLessonId, currentLessonID: currentLessonId)
        } else if (dayNumberFromCurrentDate < Int(lesson.dayNumber) ?? 0) && (currentWeekFromTodayDate == Int(lesson.lessonWeek) ?? 0){
            nextLessonId = lesson.lessonID
            return (nextLessonID: nextLessonId, currentLessonID: currentLessonId)
        }
    }
    
    var lessonsFirst: [Lesson] = []
    var lessonsSecond: [Lesson] = []

    for lesson in lessons {
        if Int(lesson.lessonWeek) == 1 {
            lessonsFirst.append(lesson)
        } else {
            lessonsSecond.append(lesson)
        }
    }
    
    if lessonsFirst.count != 0 && lessonsSecond.count != 0 {
        if nextLessonId == "" && currentWeekFromTodayDate == 2 {
            nextLessonId = lessonsFirst[0].lessonID
            return (nextLessonID: nextLessonId, currentLessonID: currentLessonId)
        } else if nextLessonId == "" && currentWeekFromTodayDate == 1 {
            nextLessonId = lessonsSecond[0].lessonID
            return (nextLessonID: nextLessonId, currentLessonID: currentLessonId)
        }
    }
    
    if lessonsFirst.count == 0 && lessonsSecond.count != 0 {
        nextLessonId = lessonsSecond[0].lessonID
        return (nextLessonID: nextLessonId, currentLessonID: currentLessonId)
    } else if lessonsFirst.count != 0 && lessonsSecond.count == 0 {
        nextLessonId = lessonsFirst[0].lessonID
        return (nextLessonID: nextLessonId, currentLessonID: currentLessonId)
    }
    
    
    return (nextLessonID: nextLessonId, currentLessonID: currentLessonId)
}


// MARK: - getTimeFromLessonNumber
/// Function which make lesson timeStart and timeEnd
func getTimeFromLessonNumber(lessonNumber: String) -> (timeStart: String, timeEnd: String) {
    var timeStart = ""
    var timeEnd = ""

    switch lessonNumber {
    case "1":
        timeStart = "08:30:00"
        timeEnd = "10:05:00"
    case "2":
        timeStart = "10:25:00"
        timeEnd = "12:00:00"
    case "3":
        timeStart = "12:20:00"
        timeEnd = "13:55:00"
    case "4":
        timeStart = "14:15:00"
        timeEnd = "15:50:00"
    case "5":
        timeStart = "16:10:00"
        timeEnd = "17:45:00"
    case "6":
        timeStart = "18:05:00"
        timeEnd = "19:40:00"
    default:
        timeStart = "00:00:00"
        timeEnd = "00:00:00"
    }
    
    return (timeStart: timeStart, timeEnd: timeEnd)
}


func sortLessons(lessons: [Lesson]) -> [Lesson] {
    var lessonsToSort = lessons
    
    lessonsToSort.sort { (lesson1, lesson2) -> Bool in
        if lesson1.lessonWeek == lesson2.lessonWeek && lesson1.dayNumber == lesson2.dayNumber {
            return lesson1.lessonNumber < lesson2.lessonNumber
        } else if lesson1.lessonWeek == lesson2.lessonWeek {
            return lesson1.dayNumber < lesson2.dayNumber
        } else {
            return lesson1.lessonWeek < lesson2.lessonWeek
        }
    }
    
    return lessonsToSort
}


func getGroupsOfLessonString(lesson: Lesson) -> String {
    var groupsNames: String  = ""

    if let groups = lesson.groups {
        var groupsSorted: [Group] = []
        groupsSorted = groups.sorted { (group1, group2) -> Bool in
            return group1.groupFullName < group2.groupFullName
        }
        for i in 0..<groupsSorted.count {
            let group = groupsSorted[i]
            if i == groups.count - 1 {
                groupsNames += group.groupFullName.uppercased()
            } else {
                groupsNames += group.groupFullName.uppercased() + ", "
            }
        }
    }
    
    return groupsNames
}
