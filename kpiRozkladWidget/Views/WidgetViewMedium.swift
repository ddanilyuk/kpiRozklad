//
//  WidgetViewMedium.swift
//  kpiRozkladSwiftUI
//
//  Created by Денис Данилюк on 27.06.2020.
//

#if canImport(WidgetKit)
import SwiftUI
import WidgetKit


struct WidgetViewMedium: View {
    
    @Environment(\.redactionReasons) var redactionReasons

    var lessons: [Lesson]
    
    var settings = Settings.shared

    let leftGradientColor: Color = Color(red: 44 / 255, green: 90 / 255, blue: 180 / 255)

    let rightGradientColor: Color = Color(red: 87 / 255, green: 157 / 255, blue: 130 / 255)

    var date: Date
    
    init(lessons: [Lesson], date: Date) {
        self.lessons = lessons
        self.date = date
    }
    
    var body: some View {
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: [leftGradientColor, rightGradientColor]),
                           startPoint: .leading,
                           endPoint: .trailing)
                .edgesIgnoringSafeArea(.all)
            
            if self.lessons != Lesson.defaultArratOfLesson {
                VStack(alignment: .leading, spacing: 1) {
                    let name = settings.groupName.uppercased()
                    
                    Text("\(name != "" ? name : "Мій розклад")")
                        .font(.body).bold()
                        .padding(.leading, 20)
                        .padding(.top, -6)
                        .padding(.bottom, -2)
                        .foregroundColor(Color(#colorLiteral(red: 0.9712373614, green: 0.6793045998, blue: 0, alpha: 1)))
                        .redacted(reason: redactionReasons)
                    
                    Spacer(minLength: 1.0)
                    
                    Link(destination: URL(string: "kpiRozklad://\(lessons[0].id)")!) {
                        LessonRow(lesson: lessons[0], date: date)
                            .foregroundColor(.white)
                    }
                    
                    Spacer(minLength: 3.0)
                    
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
            } else {
                SelectSheduleView()
            }
        }
    }
}

struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(0..<1) { _ in
            WidgetViewMedium(lessons: Lesson.previewLessons, date: Date(timeIntervalSince1970: 1601208000))
                .previewContext(
                    WidgetPreviewContext(family: .systemMedium))
            
            WidgetViewSmall(lessons: Lesson.previewLessons, date: Date(timeIntervalSince1970: 1601208000))
                .previewContext(
                    WidgetPreviewContext(family: .systemSmall))
        }
    }
}
#endif
