//
//  RowView.swift
//  kpiRozkladSwiftUI
//
//  Created by Денис Данилюк on 26.06.2020.
//

import SwiftUI

struct LessonRow: View {
    
    var lesson: Lesson
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                
                Text(lesson.timeStart.stringTime)
                    .padding(.leading, 3)
                    .frame(minWidth: 45, idealWidth: 45, maxWidth: 50, alignment: .center)
                    .font(.footnote)

                Text(lesson.lessonName)
                    .lineLimit(1)
                    .font(.title2)
                
                
                Spacer()
            }
                .padding(.bottom, 0)
            
            
            HStack(alignment: .center) {
                Text("")
                    .padding(.leading, 3)
                    .frame(minWidth: 45, idealWidth: 45, maxWidth: 50, alignment: .center)

                Text(lesson.teacherName)
                    .font(.subheadline)
                
                Spacer()
            }
            
            HStack(alignment: .center) {
                Text(lesson.timeEnd.stringTime)
                    .padding(.leading, 3)
                    .frame(minWidth: 45, idealWidth: 45, maxWidth: 50, alignment: .center)
                    .font(.footnote)


                Text(lesson.lessonRoom + " " + lesson.lessonType.rawValue)
                    .font(.subheadline)

                
                Spacer(minLength: 0)
                
                TimeView(lesson: lesson)

            }

        }

    }
}


struct TimeView: View {
    
    var lesson: Lesson

    var body: some View {
        
        HStack(spacing: 4.0) {
            Spacer()
            let textWithTime = getDateToStart(lesson: lesson)
            textWithTime.text
                .foregroundColor(textWithTime.color)
                .padding(.trailing, 10)
//                        .frame(width: 80)
            
        }
        .frame(width: 150)
        .font(.system(.footnote, design: .monospaced))
    }
    
    func getDateToStart(lesson: Lesson) -> (text: Text, color: Color) {
        let (dateStart, dateEnd) = getDate(lesson: lesson)
        var (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getTimeAndDayNumAndWeekOfYear()
        let date = Date()
        
        if lesson.dayNumber != dayNumberFromCurrentDate {
            
            if lesson.lessonWeek != currentWeekFromTodayDate {
                dayNumberFromCurrentDate = 7 - dayNumberFromCurrentDate
            }
            
            if abs(lesson.dayNumber - dayNumberFromCurrentDate) == 1 {
                return (text: Text("завтра"), color: Color.red)
            } else if abs(lesson.dayNumber - dayNumberFromCurrentDate) == 2 {
                return (text: Text("післязавтра"), color: Color.red)
            } else {
                let text = Text("через \(abs(lesson.dayNumber - dayNumberFromCurrentDate)) дні")
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






struct LessonRow_Previews: PreviewProvider {
    static var previews: some View {
//        ForEach(["iPhone X", "iPhone 8"], id: \.self) { deviceName in
//            LessonRow(lesson: lessonToTestRow)            .environment(\.colorScheme, .light)
//        }
        LessonRow(lesson: Lesson.defaultLesson)
            .previewLayout(.sizeThatFits)
    }
}
