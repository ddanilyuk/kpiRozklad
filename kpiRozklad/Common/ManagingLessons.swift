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
