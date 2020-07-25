//
//  RowView.swift
//  kpiRozkladSwiftUI
//
//  Created by Денис Данилюк on 26.06.2020.
//

import SwiftUI

struct LessonRow: View {
    
    var lesson: Lesson
    
    @Environment(\.redactionReasons) var redactionReasons
    
    var date: Date
    
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 2.0) {
                
                Text(lesson.timeStart.stringTime)
                    .frame(width: 45, alignment: .center)
                    .font(.caption)
                    .redacted(reason: redactionReasons)


                Text(lesson.lessonName)
                    .lineLimit(1)
                    .font(.body)
                    .redacted(reason: redactionReasons)

                
                Spacer()
            }.padding(.bottom, 0)
            
            HStack(alignment: .center, spacing: 2.0) {
                Text("")
                    .frame(width: 45, alignment: .center)

                Text(lesson.teacherName)
                    .font(.footnote)
                    .redacted(reason: redactionReasons)

                
                Spacer()
            }
            
            HStack(alignment: .center, spacing: 2.0) {
                Text(lesson.timeEnd.stringTime)
                    .frame(width: 45, alignment: .center)
                    .font(.caption)
                    .redacted(reason: redactionReasons)


                Text(lesson.lessonRoom + " " + lesson.lessonType.rawValue)
                    .font(.footnote)
                    .redacted(reason: redactionReasons)

                
                Spacer(minLength: 0)
                
                TimeView(lesson: lesson, date: date)
            }
        }
    }
}


struct LessonRow_Previews: PreviewProvider {
    static var previews: some View {
//        ForEach(["iPhone X", "iPhone 8"], id: \.self) { deviceName in
//            LessonRow(lesson: lessonToTestRow)            .environment(\.colorScheme, .light)
//        }
        LessonRow(lesson: Lesson.defaultLesson, date: Date())
            .previewLayout(.sizeThatFits)
    }
}
