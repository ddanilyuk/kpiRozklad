//
//  KPIRozkladWidget.swift
//  KPIRozkladWidget
//
//  Created by Денис Данилюк on 27.06.2020.
//

#if canImport(WidgetKit)
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
        let entry = LessonsEntry(date: Date(), lessons: Lesson.defaultArratOfLesson, lessonsUpdatedAtTime: "", lessonsMustUpdateAtTime: "", entryNumber: 0)
//        let (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getTimeAndDayNumAndWeekOfYear()
//        let arrayWithLessonsToShow = getArrayWithNextTwoLessons(dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate, managedObjectContext: managedObjectContext)
//        let entry = LessonsEntry(date: Date(), lessons: arrayWithLessonsToShow)
        
        completion(entry)
    }
    
    func timeline(with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getCurrentWeekAndDayNumber()

        var arrayWithLessonsToShow = getArrayWithNextThreeLessons(dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate, managedObjectContext: managedObjectContext)
        
        let (entries, dateToUpdate) = makeTimeLine1(arrayWithLessonsToShow: &arrayWithLessonsToShow, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
        
        let timeline = Timeline(entries: entries, policy: .after(dateToUpdate))

        completion(timeline)
    }
    
    
    
    func makeTimeLine1(arrayWithLessonsToShow: inout [Lesson], dayNumberFromCurrentDate: Int, currentWeekFromTodayDate: WeekType) -> (entries: [LessonsEntry], dateToUpdate: Date) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm dd-MM"
        
        var dateToUpdate = Date.tomorrow
        
        // Only for debug
        if arrayWithLessonsToShow[0].dayNumber == dayNumberFromCurrentDate {
            dateToUpdate = getDateStartAndEnd(of: arrayWithLessonsToShow[0]).dateStart
        }
        
        // Only for debug
        var lessonsUpdatedAtTime = dateFormatter.string(from: Date())
        var lessonsMustUpdateAtTime = dateFormatter.string(from: dateToUpdate)
        
        /// Update timeline options
        var entries = [LessonsEntry(date: Date(), lessons: arrayWithLessonsToShow, lessonsUpdatedAtTime: lessonsUpdatedAtTime, lessonsMustUpdateAtTime: lessonsMustUpdateAtTime, entryNumber: 1)]
        
        
        if arrayWithLessonsToShow[0].dayNumber == dayNumberFromCurrentDate {
            
            lessonsUpdatedAtTime = dateFormatter.string(from: getDateStartAndEnd(of: arrayWithLessonsToShow[0]).dateStart)
            lessonsMustUpdateAtTime = dateFormatter.string(from: getDateStartAndEnd(of: arrayWithLessonsToShow[0]).dateEnd)
            
            entries.append(LessonsEntry(date: getDateStartAndEnd(of: arrayWithLessonsToShow[0]).dateStart, lessons: arrayWithLessonsToShow, lessonsUpdatedAtTime: lessonsUpdatedAtTime, lessonsMustUpdateAtTime: lessonsMustUpdateAtTime, entryNumber: 2))
            
            lessonsUpdatedAtTime = dateFormatter.string(from: getDateStartAndEnd(of: arrayWithLessonsToShow[0]).dateEnd)
            
            dateToUpdate = getDateStartAndEnd(of: arrayWithLessonsToShow[0]).dateEnd

            /// Remove lesson which end
            arrayWithLessonsToShow.remove(at: 0)
            
            /// New entry without lesson which end. This entry presented when widget if waiting for reloading timeline.
            entries.append(LessonsEntry(date: dateToUpdate, lessons: arrayWithLessonsToShow, lessonsUpdatedAtTime: lessonsUpdatedAtTime, lessonsMustUpdateAtTime: "as soon as 1", entryNumber: 3))
            
            entries.append(LessonsEntry(date: getDateStartAndEnd(of: arrayWithLessonsToShow[0]).dateStart, lessons: arrayWithLessonsToShow, lessonsUpdatedAtTime: lessonsUpdatedAtTime, lessonsMustUpdateAtTime: "as soon as 2", entryNumber: 4))
            
        }
        
        
        return (entries: entries, dateToUpdate: dateToUpdate)
    }
}


struct LessonsEntry: TimelineEntry {
    public let date: Date
    public let lessons: [Lesson]
    public let lessonsUpdatedAtTime: String
    public let lessonsMustUpdateAtTime: String
    public let entryNumber: Int
}

struct PlaceholderView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            WidgetViewSmall(lessons: Lesson.defaultArratOfLesson, date: Date())
        case .systemMedium:
            WidgetViewMedium(lessons: Lesson.defaultArratOfLesson, date: Date())
        default:
            WidgetViewMedium(lessons: Lesson.defaultArratOfLesson, date: Date())
        }
    }
}


struct KpiRozkladWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    var entry: Provider.Entry

    // DEBUG
    var dateFormatter = DateFormatter()
    
    init (entry: Provider.Entry) {
        self.entry = entry
        
        // DEBUG
        dateFormatter.dateFormat = "HH:mm:ss dd"
    }
    
    
    @ViewBuilder
    var body: some View {
        
        switch family {
        case .systemSmall:
            WidgetViewSmall(lessons: entry.lessons, date: entry.date)
        case .systemMedium:
            // DEBUG
            VStack(alignment: .center) {
                Spacer()
                HStack {
                    Text(entry.lessonsUpdatedAtTime)
                        .foregroundColor(.blue)
                        .font(.caption)
                    Divider()
                    Text(entry.lessonsMustUpdateAtTime)
                        .foregroundColor(.red)
                        .font(.caption)

                    Divider()
                    Text("\(entry.entryNumber) | \(dateFormatter.string(from: Date()))")
                        .foregroundColor(.green)
                        .font(.caption)

                }
                WidgetViewMedium(lessons: entry.lessons, date: entry.date)
                    .padding(.top, -10)
            }
            
            // Default
            // WidgetViewMedium(lessons: entry.lessons, date: entry.date)

        default:
            WidgetViewMedium(lessons: entry.lessons, date: entry.date)
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
        WidgetViewMedium(lessons: Lesson.defaultArratOfLesson, date: Date())
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
#endif
