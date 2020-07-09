//
//  TimeView.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 09.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import SwiftUI

struct TimeView: View {
    
    var lesson: Lesson

    var body: some View {
        
        HStack(spacing: 4.0) {
            Spacer()
            let textWithTime = getDateToStart(lesson: lesson)
            textWithTime.text
//                .foregroundColor(textWithTime.color)
                .foregroundColor(Color.white)

                .padding(.trailing, 0)
            
        }
        .font(.system(.footnote, design: .monospaced))
    }
    
    func getDateToStart(lesson: Lesson) -> (text: Text, color: Color) {
        let (dateStart, dateEnd) = getDate(lesson: lesson)
        var (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getTimeAndDayNumAndWeekOfYear()
        let date = Date()
        
        if lesson.dayNumber != dayNumberFromCurrentDate {
            
            if lesson.lessonWeek != currentWeekFromTodayDate {
                dayNumberFromCurrentDate = dayNumberFromCurrentDate - 7
            }
            
            // dayNumber = 1
            // curreent = 5 next week = 5 - 7 = -2
            
            // 1 - -2 = 3
            if lesson.dayNumber - dayNumberFromCurrentDate == 1 {
                return (text: Text("завтра"), color: Color.red)
            } else if lesson.dayNumber - dayNumberFromCurrentDate == 2 {
                return (text: Text("післязавтра"), color: Color.red)
            } else {
                let text = Text("через \(lesson.dayNumber - dayNumberFromCurrentDate) дні")
                return (text: text, color: Color.red)
            }
        } else {
            //  && lesson.lessonWeek == currentWeekFromTodayDate && lesson.dayNumber == dayNumberFromCurrentDate
            if dateStart > date {
                return (text: Text("через ") + Text(dateStart, style: .timer), color: Color(UIColor.label))
            } else if dateStart < date && dateEnd > date {
                return (text: Text("ще ") + Text(dateEnd, style: .timer), color: Color(UIColor.label))
            }
        }
        
        return (text: Text("завтра"), color: Color.red)
        
    }
}

struct TimeView_Previews: PreviewProvider {
    static var previews: some View {
        TimeView(lesson: Lesson.defaultLesson)
    }
}
