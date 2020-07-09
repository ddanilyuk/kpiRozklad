//
//  LessonsHelpers.swift
//  kpiRozkladSwiftUI
//
//  Created by Денис Данилюк on 04.07.2020.
//

import UIKit
import CoreData

func getDate(lesson: Lesson) -> (dateStart: Date, dateEnd: Date) {
    let timeStart = lesson.timeStart.stringTime
    let timeEnd = lesson.timeEnd.stringTime
    
    let dateNow = Date()

    let formatterFull = DateFormatter()
    formatterFull.dateFormat = "YYYY:MM:DD:HH:mm"

    let formatterInWhichTimeSaved = DateFormatter()
    formatterInWhichTimeSaved.dateFormat = "YYYY:MM:DD"
    let fullYearMonthDay = formatterInWhichTimeSaved.string(from: dateNow)

    let dateStartInit = formatterFull.date(from: "\(fullYearMonthDay):\(timeStart)") ?? Date()
    let dateEndInit = formatterFull.date(from: "\(fullYearMonthDay):\(timeEnd)") ?? Date()
    
    return (dateStart: dateStartInit, dateEnd: dateEndInit)
    
//        let toStartPair = dateStartInit.timeIntervalSince1970 - dateNow.timeIntervalSince1970
//        let toEndPair = dateEndInit.timeIntervalSince1970 - dateNow.timeIntervalSince1970
}


func getTimeAndDayNumAndWeekOfYear() -> (dayNumberFromCurrentDate: Int, currentWeekFromTodayDate: WeekType){
    /// Current date from device
    let date = Date()
    
    /// Calendar
    let calendar = Calendar(identifier: .gregorian)
    
    /// Get number of week (in year) and weekday
    let components = calendar.dateComponents([.weekOfYear, .month, .day, .weekday], from: date)

    var dayNumberFromCurrentDate = (components.weekday ?? 0) - 1
    var weekOfYear = components.weekOfYear ?? 0

    /// In USA calendar week start on Sunday but in my shedule it start from mounday
    /// and if today is Sunday, in USA we start new week but for me its wrong and we take away one week and set dayNumber == 7
    if dayNumberFromCurrentDate == 0 {
        weekOfYear -= 1
        dayNumberFromCurrentDate = 7
    }
    
    var currentWeekFromTodayDate: WeekType = .first
    
    currentWeekFromTodayDate = weekOfYear % 2 == 0 ? .first : .second

    return (dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
}


func getNextTwoLessonsID(lessons: [Lesson], dayNumberFromCurrentDate: Int, currentWeekFromTodayDate: WeekType) -> (firstNextLessonID: Int, secondNextLessonID: Int) {
    
    // Init values
    var firstNextLessonID: Int = 0
    var secondNextLessonID: Int = 0

    // Current date
    let date = Date()
    
    // If next lesson in current week
    for lessonIndex in 0..<lessons.count {
        let lesson = lessons[lessonIndex]
        let (currentLessonsDateStart, currentLessonsDateEnd) = getDate(lesson: lesson)
        // (currentLessonsDateStart > date || (currentLessonsDateStart < date && currentLessonsDateEnd > date)) &&
        
        let isLessonToday = lesson.dayNumber == dayNumberFromCurrentDate && (currentLessonsDateStart > date || (currentLessonsDateStart < date && currentLessonsDateEnd > date))
        
        if lesson.lessonWeek == currentWeekFromTodayDate && (isLessonToday || lesson.dayNumber > dayNumberFromCurrentDate) {
            
            firstNextLessonID = lesson.id
            secondNextLessonID = lessonIndex != lessons.count + 1 ? lessons[lessonIndex + 1].id : lessons[0].id
            
            return (firstNextLessonID: firstNextLessonID, secondNextLessonID: secondNextLessonID)
        }
    }
    
    // If we not found lesson in currentWeek we choose first lesson from nextWeek
    if firstNextLessonID == 0 && secondNextLessonID == 0 {
        if currentWeekFromTodayDate == .first {
            let firstNextLesson = lessons.first { $0.lessonWeek == .second }
            
            if let lesson = firstNextLesson {
                let index = lessons.firstIndex(where: { $0.id  == lesson.id }) ?? 0
                
                if index != lessons.count + 1 {
                    return (firstNextLessonID: lessons[index].id, secondNextLessonID: lessons[index + 1].id)
                }
                
            }
        } else if currentWeekFromTodayDate == .second {
            if lessons.count > 1 {
                return (firstNextLessonID: lessons[0].id, secondNextLessonID: lessons[1].id)
            }
        }
    }
    
    return (firstNextLessonID: firstNextLessonID, secondNextLessonID: secondNextLessonID)
        
}


func getArrayWithNextTwoLessons(dayNumberFromCurrentDate: Int, currentWeekFromTodayDate: WeekType, managedObjectContext: NSManagedObjectContext) -> [Lesson] {
    guard let lessonsCoreData = try? managedObjectContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "LessonData")) as? [LessonData] else { return Lesson.defaultArratOfLesson }
    
    if lessonsCoreData.count < 3 {
        return Lesson.defaultArratOfLesson
    }
    
    var lessonsFromCoreData: [Lesson] = []
    
    lessonsFromCoreData.append(contentsOf: lessonsCoreData.map({
        $0.wrappedLesson
    }))
    
    let (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getTimeAndDayNumAndWeekOfYear()
    let (firstNextLessonID, secondNextLessonID) = getNextTwoLessonsID(lessons: lessonsFromCoreData, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
    
    var arrayWithLessonsToShow: [Lesson] = []
    if let firstLesson = lessonsFromCoreData.first(where: { return $0.id == firstNextLessonID }),
       let secondLesson = lessonsFromCoreData.first(where: { return $0.id == secondNextLessonID }) {
        arrayWithLessonsToShow = [firstLesson, secondLesson]
    }
    return arrayWithLessonsToShow
}
