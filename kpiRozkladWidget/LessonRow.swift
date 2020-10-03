//
//  RowView.swift
//  kpiRozkladSwiftUI
//
//  Created by Денис Данилюк on 26.06.2020.
//

import SwiftUI


struct LessonRow: View {
    
    var lesson: Lesson
    
    var date: Date
    
    @Environment(\.redactionReasons) var redactionReasons
    
    @State private var textMinWidth: CGFloat?

    var body: some View {
        VStack {
            HStack(alignment: VerticalAlignment.firstTextBaseline, spacing: 8.0) {
                
                Text(lesson.timeStart.stringTime)
                    .font(.caption)
                    .equalWidth($textMinWidth)
                    .redacted(reason: redactionReasons)

                Text(lesson.lessonName)
                    .lineLimit(1)
                    .font(.body)
                    .redacted(reason: redactionReasons)
                
                Spacer()
            }.padding(.bottom, 0)
            
            HStack(alignment: .center, spacing: 8.0) {
                
                Text("00:00")
                    .foregroundColor(.clear)
                    .font(.caption)
                    .equalWidth($textMinWidth)

                Text(lesson.teacherName.deleteLeftWhitespaces())
                    .font(.caption)
                    .redacted(reason: redactionReasons)
                
                Spacer()
            }
            
            HStack(alignment: VerticalAlignment.firstTextBaseline, spacing: 8.0) {
                Text(lesson.timeEnd.stringTime)
                    .font(.caption)
                    .equalWidth($textMinWidth)
                    .redacted(reason: redactionReasons)

                let lessonRoomAndType = lesson.lessonRoom + " " + lesson.lessonType.rawValue
                Text(lessonRoomAndType.deleteLeftWhitespaces())
                    .font(.caption)
                    .redacted(reason: redactionReasons)
                
                Spacer(minLength: 0)
                
                TimeView(lesson: lesson, date: date)
            }
        }
    }
}

//
//struct LessonRow_Previews: PreviewProvider {
//    static var previews: some View {
////        ForEach(["iPhone X", "iPhone 8"], id: \.self) { deviceName in
////            LessonRow(lesson: lessonToTestRow)            .environment(\.colorScheme, .light)
////        }
//        LessonRow(lesson: Lesson.defaultLesson, date: Date())
//            .previewLayout(.sizeThatFits)
//            .redacted(reason: .placeholder)
//            .prev
//
////            .environmentObject(RedactionReasons().placeholder)
//        //            .previewContext(_)
//    }
//}
