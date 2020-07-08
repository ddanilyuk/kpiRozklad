//
//  WidgetViewMedium.swift
//  kpiRozkladSwiftUI
//
//  Created by Денис Данилюк on 27.06.2020.
//

import SwiftUI
import WidgetKit


struct WidgetViewMedium: View {
    
    var lessons: [Lesson]
    
    var settings = Settings.shared
    
    init(lessons: [Lesson]) {
        self.lessons = lessons
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let name = settings.groupName.uppercased()
            
            Text("\(name != "" ? name : "Мій розклад")")
                .font(.headline)
                .padding(.leading, 30)
                .padding(.top, -8)
//                .padding(.bottom, 2)
                .foregroundColor(.blue)
//                .frame(width: 250, alignment: .leading)

            
            ZStack {
                Color.clear
//                Color.purple

                LessonRow(lesson: lessons[0])
                    .foregroundColor(.init(UIColor.label))
//                    .foregroundColor(.white)
                    
//                    .padding([.leading, .trailing], 4)
//                    .frame(height: 55)
            }
            
            Color(UIColor.secondarySystemBackground)
                .frame(height: 1, alignment: .center)
            
            ZStack {
                Color.clear
                LessonRow(lesson: lessons[1])
                    .foregroundColor(.init(UIColor.label))
//                    .padding([.leading, .trailing], 4)
//                    .frame(height: 55)
            }

//            Spacer()
        }
//        .padding(.vertical, 8)
        .padding(.all, 16)

    }
    
    
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
//        WidgetViewMedium(lessons: Lesson.defaultArratOfLesson)
//            .frame(width: 329, height: 155)
//            .previewLayout(.fixed(width: 329, height: 155))
        
        WidgetViewMedium(lessons: Lesson.defaultArratOfLesson)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
