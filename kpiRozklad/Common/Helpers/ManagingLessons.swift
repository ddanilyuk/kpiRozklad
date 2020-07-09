//
//  ManagingLessons.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 30.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit


// MARK: - getCurrentAndNextLesson
/**
Find current and next lesson ID

 - Parameter lessons: Lessons in which need find current and next
 - Parameter timeIsNowString: Time is now in string
 - Parameter dayNumberFromCurrentDate: Current day number [1-7]
 - Parameter currentWeekFromTodayDate: Current week number [1-2]

  - Returns: Next and current lesson ID
*/
func getCurrentAndNextLesson(lessons: [Lesson],
                             timeIsNowString: String,
                             dayNumberFromCurrentDate: Int,
                             currentWeekFromTodayDate: WeekType) ->
                             (nextLessonID: Int, currentLessonID: Int) {
    
    var nextLessonId: Int = 0
    var currentLessonId: Int = 0
    
    for lesson in lessons {
        
        let timeStart = lesson.timeStart.stringTime
        let timeEnd = lesson.timeEnd.stringTime
                    
        if (timeStart <= timeIsNowString) && (timeIsNowString < timeEnd) &&
            (dayNumberFromCurrentDate == lesson.dayNumber) && (currentWeekFromTodayDate == lesson.lessonWeek) {
            currentLessonId = lesson.id
        }
        
        if (timeStart > timeIsNowString) && (dayNumberFromCurrentDate == lesson.dayNumber) && (currentWeekFromTodayDate == lesson.lessonWeek) {
            nextLessonId = lesson.id
            return (nextLessonID: nextLessonId, currentLessonID: currentLessonId)
        } else if (dayNumberFromCurrentDate < lesson.dayNumber) && (currentWeekFromTodayDate == lesson.lessonWeek) {
            nextLessonId = lesson.id
            return (nextLessonID: nextLessonId, currentLessonID: currentLessonId)
        }
    }
    
    var lessonsFirst: [Lesson] = []
    var lessonsSecond: [Lesson] = []

    for lesson in lessons {
        if lesson.lessonWeek == .first {
            lessonsFirst.append(lesson)
        } else {
            lessonsSecond.append(lesson)
        }
    }
    
    if lessonsFirst.count != 0 && lessonsSecond.count != 0 {
        if nextLessonId == 0 && currentWeekFromTodayDate == .second {
            nextLessonId = lessonsFirst[0].id
            return (nextLessonID: nextLessonId, currentLessonID: currentLessonId)
        } else if nextLessonId == 0 && currentWeekFromTodayDate == .first {
            nextLessonId = lessonsSecond[0].id
            return (nextLessonID: nextLessonId, currentLessonID: currentLessonId)
        }
    }
    
    if lessonsFirst.count == 0 && lessonsSecond.count != 0 {
        nextLessonId = lessonsSecond[0].id
        return (nextLessonID: nextLessonId, currentLessonID: currentLessonId)
    } else if lessonsFirst.count != 0 && lessonsSecond.count == 0 {
        nextLessonId = lessonsFirst[0].id
        return (nextLessonID: nextLessonId, currentLessonID: currentLessonId)
    }
    
    
    return (nextLessonID: nextLessonId, currentLessonID: currentLessonId)
}


/**
 Make lesson timeStart and timeEnd

 - Parameter currentWeekFromTodayDate: Current week number [1-2]

  - Returns: timeStart and timeEnd
 */
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


/**
 Sort lessons in normal order
 
 - Parameter lessons: Lessons to sort
 
  - Returns: Sorted lessons
 */
func sortLessons(lessons: [Lesson]) -> [Lesson] {
    var lessonsToSort = lessons
    
    lessonsToSort.sort { (lesson1, lesson2) -> Bool in
        if lesson1.lessonWeek == lesson2.lessonWeek && lesson1.dayNumber == lesson2.dayNumber {
            return lesson1.lessonNumber < lesson2.lessonNumber
        } else if lesson1.lessonWeek == lesson2.lessonWeek {
            return lesson1.dayNumber < lesson2.dayNumber
        } else {
            return lesson1.lessonWeek.rawValue < lesson2.lessonWeek.rawValue
        }
    }
    
    return lessonsToSort
}


/**
 Make string with groups in lesson

- Parameter lessons: lesson

 - Returns: String with groups  like `"ІВ-81, ІВ-82, IВ-83"`
*/
func getGroupsOfLessonString(lesson: Lesson) -> String {
    var groupsNames: String = ""

    if let groups = lesson.groups {
        var groupsSorted: [Group?] = []
        groupsSorted = groups.sorted { (group1, group2) -> Bool in
            return group1?.groupFullName ?? "1" < group2?.groupFullName ?? "2"
        }
        
        for i in 0..<groupsSorted.count {
            if let group = groupsSorted[i] {
                if i == groups.count - 1 {
                    groupsNames += group.groupFullName.uppercased()
                } else {
                    groupsNames += group.groupFullName.uppercased() + ", "
                }
            }
        }
    }
    
    return groupsNames
}
