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
    
    let color1: Color = Color(red: 57 / 255, green: 117 / 255, blue: 243 / 255)
    
    let color2: Color = Color(red: 117 / 255, green: 210 / 255, blue: 174 / 255)
    
//    let color2: Color = Color(red: 89 / 255, green: 166 / 255, blue: 216 / 255)


    
    init(lessons: [Lesson]) {
        self.lessons = lessons
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient:
                                Gradient(colors: [color1, color2]),
                           startPoint: .leading, endPoint: .trailing)
                .edgesIgnoringSafeArea(.all)
            
            Color.black.opacity(0.25)
                .edgesIgnoringSafeArea(.all)

            
            VStack(alignment: .leading, spacing: 0) {
                let name = settings.groupName.uppercased()
                
                Text("\(name != "" ? name : "Мій розклад")")
                    .font(.headline)
                    .padding(.leading, 30)
                    .padding(.top, -8)
                    .foregroundColor(Color(#colorLiteral(red: 0.9712373614, green: 0.6793045998, blue: 0, alpha: 1)))
                
                Spacer(minLength: 0.0)
                
                LessonRow(lesson: lessons[0])
                    .foregroundColor(.white)
                
                Spacer(minLength: 0.0)
                
                Color(UIColor.white)
                    .opacity(0.5)
                    .frame(height: 1, alignment: .center)
                
                Spacer(minLength: 0.0)

                LessonRow(lesson: lessons[1])
                    .foregroundColor(.white)
                
            }
            .padding()
        }

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
