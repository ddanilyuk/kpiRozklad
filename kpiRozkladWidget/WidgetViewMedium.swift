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
    
    // first
//    let color1: Color = Color(red: 57 / 255, green: 117 / 255, blue: 243 / 255)
    let color1: Color = Color(red: 44 / 255, green: 90 / 255, blue: 180 / 255)
    
//    let colorTest1: Color = Color(UIColor(red: 57 / 255, green: 117 / 255, blue: 243 / 255, alpha: 1))

    let colorTest1: Color = Color(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1))

    
    

    // second
//    let color2: Color = Color(red: 117 / 255, green: 210 / 255, blue: 174 / 255)
    let color2: Color = Color(red: 87 / 255, green: 157 / 255, blue: 130 / 255)
    
//    let colorTest2: Color = Color(UIColor(red: 117 / 255, green: 210 / 255, blue: 174 / 255, alpha: 1))
    
    let colorTest2: Color = Color(#colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1))



//    let color2: Color = Color(red: 89 / 255, green: 166 / 255, blue: 216 / 255)


    var date: Date
    
    init(lessons: [Lesson], date: Date) {
        self.lessons = lessons
        self.date = date
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient:
                            Gradient(colors: [color1, color2]),
                           startPoint: .leading,
                           endPoint: .trailing)
                .edgesIgnoringSafeArea(.all)
            
            Color.black.opacity(0.0)
                .edgesIgnoringSafeArea(.all)

            
            VStack(alignment: .leading, spacing: 0) {
                let name = settings.groupName.uppercased()
                
                Text("\(name != "" ? name : "Мій розклад")")
                    .font(.headline)
                    .padding(.leading, 30)
                    .padding(.top, -8)
                    .foregroundColor(Color(#colorLiteral(red: 0.9712373614, green: 0.6793045998, blue: 0, alpha: 1)))
                
                Spacer(minLength: 0.0)
                
                Link(destination: URL(string: "kpiRozklad://\(lessons[0].id)")!) {
                    LessonRow(lesson: lessons[0], date: date)
                        .foregroundColor(.white)
                }
                
                Spacer(minLength: 0.0)
                
                Color(UIColor.white)
                    .opacity(0.5)
                    .frame(height: 1, alignment: .center)
                
                Spacer(minLength: 0.0)
                
                Link(destination: URL(string: "kpiRozklad://\(lessons[1].id)")!) {
                    LessonRow(lesson: lessons[1], date: date)
                        .foregroundColor(.white)
                }
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
        
        WidgetViewMedium(lessons: Lesson.defaultArratOfLesson, date: Date())
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
