//
//  KPIRozkladWidget.swift
//  KPIRozkladWidget
//
//  Created by Денис Данилюк on 27.06.2020.
//

import WidgetKit
import SwiftUI
import CoreData


struct Provider: TimelineProvider {
    
    var managedObjectContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    typealias Entry = LessonsEntry

    func snapshot(with context: Context, completion: @escaping (Entry) -> ()) {
        let entry = LessonsEntry(date: Date(), lessons: Lesson.defaultArratOfLesson)
//        let (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getTimeAndDayNumAndWeekOfYear()
//        let arrayWithLessonsToShow = getArrayWithNextTwoLessons(dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate, managedObjectContext: managedObjectContext)
//        let entry = LessonsEntry(date: Date(), lessons: arrayWithLessonsToShow)
        
        completion(entry)
    }
    
    func timeline(with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getTimeAndDayNumAndWeekOfYear()

        let arrayWithLessonsToShow = getArrayWithNextTwoLessons(dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate, managedObjectContext: managedObjectContext)
        
    
        // Update timeline options
        var entries = [LessonsEntry(date: Date(), lessons: arrayWithLessonsToShow)]
            
        var dateToUpdate = Date.tomorrow
        
        if arrayWithLessonsToShow[0].dayNumber == dayNumberFromCurrentDate {
            entries.append(LessonsEntry(date: getDate(lesson: arrayWithLessonsToShow[0]).dateStart, lessons: arrayWithLessonsToShow))
            entries.append(LessonsEntry(date: getDate(lesson: arrayWithLessonsToShow[0]).dateEnd, lessons: arrayWithLessonsToShow))
            dateToUpdate = getDate(lesson: arrayWithLessonsToShow[0]).dateEnd
        }
                
        let timeline = Timeline(entries: entries, policy: .after(dateToUpdate))
        
        completion(timeline)
    }    
}


struct LessonsEntry: TimelineEntry {
    public let date: Date
    public let lessons: [Lesson]

}

struct PlaceholderView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall: WidgetViewSmall(lessons: Lesson.defaultArratOfLesson)
        case .systemMedium: WidgetViewMedium(lessons: Lesson.defaultArratOfLesson)
        default: WidgetViewMedium(lessons: Lesson.defaultArratOfLesson)
        }
    }
}


struct KpiRozkladWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall: WidgetViewSmall(lessons: entry.lessons)
        case .systemMedium: WidgetViewMedium(lessons: entry.lessons)
        default: WidgetViewMedium(lessons: entry.lessons)
        }
    }
}

@main
struct KPIRozkladWidget: Widget {
    private let kind: String = "KPIRozkladWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: Provider(context: persistentContainer.viewContext),
                            placeholder: PlaceholderView()
        ) { entry in
            KpiRozkladWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Kpi Rozklad Widget")
        .description("Widget with your shedule")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
    
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSCustomPersistentContainer(name: "kpiRozkladModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

struct kpiRozkladWidget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetViewMedium(lessons: Lesson.defaultArratOfLesson)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
