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
    
    let color1: Color = Color(red: 57 / 255, green: 117 / 255, blue: 243 / 255)
    
    let color2: Color = Color(red: 117 / 255, green: 210 / 255, blue: 174 / 255)
    
    init(lessons: [Lesson]) {
        if lessons.count > 0 {
            self.lesson = lessons[0]
        }
    }
    
    var body: some View {
        
        ZStack {
            LinearGradient(gradient:
                                Gradient(colors: [color1, color2]),
                           startPoint: .leading, endPoint: .trailing)
                .edgesIgnoringSafeArea(.all)
            
            Color.black.opacity(0.25)
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 0.0) {
                
                let dateLesson = getDate(lesson: lesson)
                let date = Date()
                let text = dateLesson.dateStart < date && dateLesson.dateEnd > date ? "Зараз" : "Далі"
                
                Text(text)
                    .font(.headline)
                    .lineLimit(1)
//                    .foregroundColor(.white)
                    .foregroundColor(Color(#colorLiteral(red: 0.9712373614, green: 0.6793045998, blue: 0, alpha: 1)))


                VStack(alignment: .leading) {
                    
                    Spacer(minLength: 0.0)
                    
                    Text(lesson.lessonFullName)
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

                    Text(lesson.lessonRoom + " " + lesson.lessonType.rawValue)
                        .font(.footnote)
                        .foregroundColor(.white)

                    Spacer(minLength: 0.0)

                    TimeView(lesson: lesson)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.white)

                }
            }
            .padding()
        }

    }
}

struct WidgetViewSmall_Previews: PreviewProvider {
    static var previews: some View {
        WidgetViewSmall(lessons: Lesson.defaultArratOfLesson)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
