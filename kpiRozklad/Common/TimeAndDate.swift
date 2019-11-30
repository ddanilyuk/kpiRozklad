//
//  TimeAndDate.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 30.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

// MARK: - getDayNumAndWeekOfYear
/// Getting dayNumber and week of year from device Date()
func getTimeAndDayNumAndWeekOfYear() -> (timeIsNowString: String, dayNumberFromCurrentDate: Int, weekOfYear: Int){
    /// Current date from device
    let date = Date()
    
    /// Calendar
    let calendar = Calendar.current
    
    /// "HH:mm"  formatter (hours and minutes)
    let formatter2 = DateFormatter()

    formatter2.dateFormat = "HH:mm"
    
    /// time is now
    let timeIsNowString = formatter2.string(from: date)
    
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
    
    return (timeIsNowString: timeIsNowString, dayNumberFromCurrentDate: dayNumberFromCurrentDate, weekOfYear: weekOfYear)

}



