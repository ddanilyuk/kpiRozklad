//
//  LessonsHelpers.swift
//  kpiRozkladSwiftUI
//
//  Created by Денис Данилюк on 04.07.2020.
//

import UIKit

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
