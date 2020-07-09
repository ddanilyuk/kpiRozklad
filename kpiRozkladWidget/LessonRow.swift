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
            HStack(alignment: .center, spacing: 2.0) {
                
                Text(lesson.timeStart.stringTime)
                    .frame(width: 40, alignment: .center)
                    .font(.caption)

                Text(lesson.lessonName)
                    .lineLimit(1)
                    .font(.body)
                
                Spacer()
            }.padding(.bottom, 0)
            
            HStack(alignment: .center, spacing: 2.0) {
                Text("")
                    .frame(width: 40, alignment: .center)

                Text(lesson.teacherName)
                    .font(.footnote)
                
                Spacer()
            }
            
            HStack(alignment: .center, spacing: 2.0) {
                Text(lesson.timeEnd.stringTime)
                    .frame(width: 40, alignment: .center)
                    .font(.caption)


                Text(lesson.lessonRoom + " " + lesson.lessonType.rawValue)
                    .font(.footnote)

                
                Spacer(minLength: 0)
                
                TimeView(lesson: lesson)
                    .frame(width: 150)
            }

        }

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
