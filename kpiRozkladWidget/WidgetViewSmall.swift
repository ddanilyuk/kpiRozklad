//
//  WidgetViewSmall.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 08.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import SwiftUI
import WidgetKit

struct WidgetViewSmall: View {
    
    var lesson: Lesson = Lesson.defaultLesson
    
    var settings = Settings.shared
    
    init(lessons: [Lesson]) {
        if lessons.count > 0 {
            self.lesson = lessons[0]
        }
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0.0) {
            
            let dateLesson = getDate(lesson: lesson)
            let date = Date()
            let text = dateLesson.dateStart < date && dateLesson.dateEnd > date ? "Зараз" : "Наступна пара"
            
            Text(text)
                .font(.headline)

//                .padding(.bottom, 8)
                .foregroundColor(.blue)
//                .frame(alignment: .center)
//            Spacer()
            
            
            VStack(alignment: .leading) {
//                Spacer(minLength: 0.0)
                
                Spacer(minLength: 0.0)

                Text(lesson.lessonFullName)
                    .font(.body)
                    .lineLimit(2)
                    .lineSpacing(0.0)

                Spacer(minLength: 0.0)

                Text((lesson.teacher?.teacherShortName == "" ? lesson.teacherName : lesson.teacher?.teacherShortName) ?? lesson.teacherName)
                    .font(.footnote)
                    .lineLimit(1)

                Spacer(minLength: 0.0)


                Text(lesson.lessonRoom + " " + lesson.lessonType.rawValue)
                    .font(.footnote)

                Spacer(minLength: 0.0)

                TimeView(lesson: lesson)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            }
//            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
//            .background(Color.red)

        }
//        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
//        .background(Color.green)

//        .padding(.all, 10)
        .padding(.all, 16)

    }
}

struct WidgetViewSmall_Previews: PreviewProvider {
    static var previews: some View {
        WidgetViewSmall(lessons: Lesson.defaultArratOfLesson)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
