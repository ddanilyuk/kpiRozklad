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
            
            let textWithTime = getTextFromLessonTime(lesson: lesson)
            
            textWithTime.text1 + textWithTime.text2
        }
        .foregroundColor(Color.white)
        .padding(.trailing, 0)
        .font(.system(.footnote, design: .monospaced))
        .frame(alignment: .trailing)
        .multilineTextAlignment(.trailing)
    }
    
    
    func getTextFromLessonTime(lesson: Lesson) -> (text1: Text, text2: Text) {
        let (dateStart, dateEnd) = getDateStartAndEnd(of: lesson)
        var (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getCurrentWeekAndDayNumber()
        
        if lesson.dayNumber != dayNumberFromCurrentDate {
            
            if lesson.lessonWeek != currentWeekFromTodayDate {
                dayNumberFromCurrentDate = dayNumberFromCurrentDate - 7
            }

            if lesson.dayNumber - dayNumberFromCurrentDate == 1 {
                return (text1: Text("завтра"), text2: Text(""))
            } else if lesson.dayNumber - dayNumberFromCurrentDate == 2 {
                return (text1: Text("післязавтра"), text2: Text(""))
            } else {
                let text = Text("через \(lesson.dayNumber - dayNumberFromCurrentDate) дні")
                return (text1: text, text2: Text(""))
            }
        } else {
            if dateStart > date {
                return (text1: Text("через "), text2: Text(dateStart, style: .timer))
            } else if dateStart <= date && dateEnd > date {
                return (text1: Text("ще "), text2: Text(dateEnd, style: .timer))
            }
        }
        
        return (text1: Text("закінчилося"), text2: Text(""))
    }
}


struct TimeView_Previews: PreviewProvider {
    static var previews: some View {
        TimeView(lesson: Lesson.defaultLesson, date: Date())
    }
}
