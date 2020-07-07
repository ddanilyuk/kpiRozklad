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
        VStack(alignment: .center) {
            Text("Наступна пара")
                .font(.headline)
//                .padding(.bottom, 8)
                .foregroundColor(.blue)
                .frame(alignment: .center)
            
            Spacer()
            VStack(alignment: .leading) {
                Text(lesson.lessonFullName)
                    .font(.title2)
                    .lineLimit(2)
    //            Spacer()

                Text(lesson.teacher?.teacherShortName ?? lesson.teacherName)
                    .font(.subheadline)
                    .lineLimit(1)


                Text(lesson.lessonRoom + " " + lesson.lessonType.rawValue)
                    .font(.subheadline)
                
                Spacer()

                TimeView(lesson: lesson)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                
                
                    
            }

        }
        .padding(.all, 8)
    }
}

struct WidgetViewSmall_Previews: PreviewProvider {
    static var previews: some View {
        WidgetViewSmall(lessons: Lesson.defaultArratOfLesson)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
