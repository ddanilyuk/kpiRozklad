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
            getTextFromLessonTime(lesson: lesson)
                .lineLimit(1)
        }
        .foregroundColor(Color.white)
        .padding(.trailing, 0)
        .font(.system(.footnote, design: .monospaced))
        .frame(alignment: .trailing)
        .multilineTextAlignment(.trailing)
    }
    
    
    func getTextFromLessonTime(lesson: Lesson) -> Text {
        let (dateStart, dateEnd) = getDateStartAndEnd(of: lesson)
        var (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getCurrentWeekAndDayNumber(date: date)
        
        if lesson.dayNumber != dayNumberFromCurrentDate {
            if lesson.lessonWeek != currentWeekFromTodayDate {
                dayNumberFromCurrentDate = dayNumberFromCurrentDate - 7
            }
            if lesson.dayNumber - dayNumberFromCurrentDate == 1 {
                return Text("завтра")
            } else if lesson.dayNumber - dayNumberFromCurrentDate == 2 {
                return Text("післязавтра")
            } else {
                return Text("через \(abs(lesson.dayNumber - dayNumberFromCurrentDate)) дні")
            }
        } else {
            if dateStart > date {
                return Text("через ") + Text(dateStart, style: .timer)
            } else if dateStart <= date && dateEnd > date {
                return Text("ще ") + Text(dateEnd, style: .timer)
            }
        }
        
        return Text("закінчилося")
    }
}


struct TimeView_Previews: PreviewProvider {
    static var previews: some View {
        TimeView(lesson: Lesson.defaultLesson, date: Date())
    }
}
