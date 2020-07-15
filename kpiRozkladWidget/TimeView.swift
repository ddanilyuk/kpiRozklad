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
    
    var date: Date

    var body: some View {
        
        HStack(spacing: 4.0) {
            Spacer()
            
            let textWithTime = getDateToStart(lesson: lesson)
            
            textWithTime.text1
                .foregroundColor(Color.white)
                .padding(.trailing, 0)
                
            
            textWithTime.text2
                .foregroundColor(Color.white)
                .padding(.trailing, 0)
                .frame(minWidth: 0)
                .frame(alignment: .leading)
        }
        .font(.system(.footnote, design: .monospaced))
    }
    
    func getDateToStart(lesson: Lesson) -> (text1: Text, text2: Text, color: Color) {
        let (dateStart, dateEnd) = getDate(lesson: lesson)
        var (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getTimeAndDayNumAndWeekOfYear()
        
        if lesson.dayNumber != dayNumberFromCurrentDate {
            
            if lesson.lessonWeek != currentWeekFromTodayDate {
                dayNumberFromCurrentDate = dayNumberFromCurrentDate - 7
            }

            if lesson.dayNumber - dayNumberFromCurrentDate == 1 {
                return (text1: Text("завтра"), text2: Text(""), color: Color.red)
            } else if lesson.dayNumber - dayNumberFromCurrentDate == 2 {
                return (text1: Text("післязавтра"), text2: Text(""), color: Color.red)
            } else {
                let text = Text("через \(lesson.dayNumber - dayNumberFromCurrentDate) дні")
                return (text1: text, text2: Text(""),  color: Color.red)
            }
        } else {
            if dateStart > date {
                return (text1: Text("через "), text2: Text(dateStart, style: .timer), color: Color(UIColor.label))
            } else if dateStart <= date && dateEnd > date {
                return (text1: Text("ще "), text2: Text(dateEnd, style: .timer), color: Color(UIColor.label))
            }
        }
        
        return (text1: Text("закінчилося"), text2: Text(""), color: Color.red)
        
    }
}

struct TimeView_Previews: PreviewProvider {
    static var previews: some View {
        TimeView(lesson: Lesson.defaultLesson, date: Date())
    }
}
