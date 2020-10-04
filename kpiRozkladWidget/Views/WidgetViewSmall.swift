//
//  WidgetViewSmall.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 08.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//


#if canImport(WidgetKit)
import SwiftUI
import WidgetKit

struct WidgetViewSmall: View {
    
    var lesson: Lesson = Lesson.defaultLesson
    
    var date: Date
    
    var settings = Settings.shared
    
    let leftGradientColor: Color = Color(red: 44 / 255, green: 90 / 255, blue: 180 / 255)
    let rightGradientColor: Color = Color(red: 87 / 255, green: 157 / 255, blue: 130 / 255)
    
    init(lessons: [Lesson], date: Date) {
        self.date = date
        if lessons.count > 0 {
            self.lesson = lessons[0]
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient:
                                Gradient(colors: [leftGradientColor, rightGradientColor]),
                           startPoint: .leading, endPoint: .trailing)
                .edgesIgnoringSafeArea(.all)
            
            if self.lesson != Lesson.defaultArratOfLesson[0] {
                VStack(alignment: .center, spacing: 0.0) {
                    
                    let dateLesson = getDateStartAndEnd(of: lesson, dateNow: date)
                    let (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getCurrentWeekAndDayNumber(date: date)
                    let isLessonToday = lesson.dayNumber == dayNumberFromCurrentDate && currentWeekFromTodayDate == lesson.lessonWeek
                    let text = dateLesson.dateStart <= date && dateLesson.dateEnd > date && isLessonToday ? "Зараз" : "Далі"
                    
                    Text(text)
                        .font(.body).bold()
                        .lineLimit(1)
                        .foregroundColor(Color(#colorLiteral(red: 0.9712373614, green: 0.6793045998, blue: 0, alpha: 1)))
                    
                    
                    VStack(alignment: .leading) {
                        
                        Spacer(minLength: 0.0)
                        
                        Text(lesson.lessonName)
                            .font(.body)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .lineSpacing(0.0)
                        
                        Spacer(minLength: 0.0)
                        
                        Text((lesson.teacher?.teacherShortName == "" ? lesson.teacherName : lesson.teacher?.teacherShortName) ?? lesson.teacherName)
                            .font(.footnote)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Spacer(minLength: 0.0)
                        
                        let lessonRoomAndType = lesson.lessonRoom + " " + lesson.lessonType.rawValue
                        Text(lessonRoomAndType.deleteLeftWhitespaces())
                            .font(.footnote)
                            .foregroundColor(.white)
                        
                        Spacer(minLength: 0.0)
                        
                        TimeView(lesson: lesson, date: date)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                        
                    }
                }
                .padding()
                .widgetURL(URL(string: "kpiRozklad://\(lesson.id)"))
            } else {
                SelectSheduleView()
            }
        }

    }
}

//struct WidgetViewSmall_Previews: PreviewProvider {
//    static var previews: some View {
//        WidgetViewSmall(lessons: Lesson.defaultArratOfLesson, date: Date())
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
#endif
