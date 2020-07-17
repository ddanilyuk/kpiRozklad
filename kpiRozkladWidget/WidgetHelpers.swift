//
//  LessonsHelpers.swift
//  kpiRozkladSwiftUI
//
//  Created by Денис Данилюк on 04.07.2020.
//

import UIKit
import CoreData


/// Get start and end date if `lesson` today
func getDateStartAndEnd(of lesson: Lesson, dateNow: Date = Date()) -> (dateStart: Date, dateEnd: Date) {
    let timeStart = lesson.timeStart.stringTime
    let timeEnd = lesson.timeEnd.stringTime
    
//    let dateNow = Date()

    let formatterFull = DateFormatter()
    formatterFull.dateFormat = "YYYY:MM:DD:HH:mm"

    let formatterInWhichTimeSaved = DateFormatter()
    formatterInWhichTimeSaved.dateFormat = "YYYY:MM:DD"
    let fullYearMonthDay = formatterInWhichTimeSaved.string(from: dateNow)

    let dateStartInit = formatterFull.date(from: "\(fullYearMonthDay):\(timeStart)") ?? Date()
    let dateEndInit = formatterFull.date(from: "\(fullYearMonthDay):\(timeEnd)") ?? Date()
    
    return (dateStart: dateStartInit, dateEnd: dateEndInit)
}


func getCurrentWeekAndDayNumber(date: Date = Date()) -> (dayNumberFromCurrentDate: Int, currentWeekFromTodayDate: WeekType) {
    /// Current date from device
    
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


func getNextThreeLessonsID(lessons: [Lesson],
                           dayNumberFromCurrentDate: Int,
                           currentWeekFromTodayDate: WeekType) -> (firstNextLessonID: Int, secondNextLessonID: Int, thirdNextLessonID: Int) {
    guard lessons.count > 3 else {
        assertionFailure("While getting three next lesson give <3 lessons")
        return (firstNextLessonID: 0, secondNextLessonID: 0, thirdNextLessonID: 0)
    }
    
    /// Init values
    var firstNextLessonID: Int = 0
    var secondNextLessonID: Int = 0
    var thirdNextLessonID: Int = 0

    /// Current date
    let date = Date()
    
    var iterator = lessons.makeIterator()
    
    while let lesson = iterator.next() {
        let (currentLessonsDateStart, currentLessonsDateEnd) = getDateStartAndEnd(of: lesson)
        
        let isLessonToday = lesson.dayNumber == dayNumberFromCurrentDate && (currentLessonsDateStart > date || (currentLessonsDateStart < date && currentLessonsDateEnd > date))
        
        if lesson.lessonWeek == currentWeekFromTodayDate && (isLessonToday || lesson.dayNumber > dayNumberFromCurrentDate) {
            
            firstNextLessonID = lesson.id
            if let secondLesson = iterator.next() {
                secondNextLessonID = secondLesson.id
                thirdNextLessonID = iterator.next()?.id ?? lessons[0].id
            } else {
                secondNextLessonID = lessons[0].id
                thirdNextLessonID = lessons[1].id
            }
            return (firstNextLessonID: firstNextLessonID, secondNextLessonID: secondNextLessonID, thirdNextLessonID: thirdNextLessonID)
        }
    }
    
    /// Lessons from second week.
    var secondWeekLessons = lessons.filter{ $0.lessonWeek == .second }
    
    /// While `secondWeekLessons.count < 3` add lessons from firstWeek
    var counter = 0
    while secondWeekLessons.count < 3 {
        secondWeekLessons.append(lessons[counter])
        counter += 1
    }
    
    iterator = currentWeekFromTodayDate == .first ? lessons.makeIterator() : secondWeekLessons.makeIterator()
    
    firstNextLessonID = iterator.next()?.id ?? 0
    secondNextLessonID = iterator.next()?.id ?? 0
    thirdNextLessonID = iterator.next()?.id ?? 0
    
    return (firstNextLessonID: firstNextLessonID, secondNextLessonID: firstNextLessonID, thirdNextLessonID: firstNextLessonID)
}


/// Fetching core data and getting lessons from `getNextThreeLessonsID()`
func getArrayWithNextThreeLessons(dayNumberFromCurrentDate: Int, currentWeekFromTodayDate: WeekType, managedObjectContext: NSManagedObjectContext) -> [Lesson] {
    guard let lessonsCoreData = try? managedObjectContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "LessonData")) as? [LessonData] else { return Lesson.defaultArratOfLesson }
    
    if lessonsCoreData.count < 4 {
        return Lesson.defaultArratOfLesson
    }
    
    var lessonsFromCoreData: [Lesson] = []
    
    lessonsFromCoreData.append(contentsOf: lessonsCoreData.map({
        $0.wrappedLesson
    }))
    
    let (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getCurrentWeekAndDayNumber()
    let (firstNextLessonID, secondNextLessonID, thirdNextLessonID) = getNextThreeLessonsID(lessons: lessonsFromCoreData, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
    
    var arrayWithLessonsToShow: [Lesson] = []
    if let firstLesson = lessonsFromCoreData.first(where: { return $0.id == firstNextLessonID }),
       let secondLesson = lessonsFromCoreData.first(where: { return $0.id == secondNextLessonID }),
       let thirdLesson = lessonsFromCoreData.first(where: { return $0.id == thirdNextLessonID }){
        arrayWithLessonsToShow = [firstLesson, secondLesson, thirdLesson]
    }
    return arrayWithLessonsToShow
}
