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
    
    typealias Entry = LessonsEntry
    
    
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    
    func placeholder(in context: Context) -> LessonsEntry {
        return LessonsEntry(date: Date(), lessons: Lesson.defaultArratOfLesson)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LessonsEntry) -> Void) {
        let (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getCurrentWeekAndDayNumber()
        
        let arrayWithLessonsToShow = getArrayWithNextThreeLessons(dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate, managedObjectContext: managedObjectContext)
        
        let entry = LessonsEntry(date: Date(), lessons: arrayWithLessonsToShow)
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LessonsEntry>) -> Void) {
        let (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getCurrentWeekAndDayNumber()
        
        var arrayWithLessonsToShow = getArrayWithNextThreeLessons(dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate, managedObjectContext: managedObjectContext)
        
        let (entries, dateToUpdate) = makeTimeLine1(arrayWithLessonsToShow: &arrayWithLessonsToShow, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
        
        let timeline = Timeline(entries: entries, policy: .after(dateToUpdate))
        
        completion(timeline)
    }
    
    /// Fetching core data and getting lessons from `getNextThreeLessonsID()`
    func getArrayWithNextThreeLessons(dayNumberFromCurrentDate: Int, currentWeekFromTodayDate: WeekType, managedObjectContext: NSManagedObjectContext) -> [Lesson] {
        guard let lessonsCoreData = try? managedObjectContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "LessonData")) as? [LessonData] else { return Lesson.defaultArratOfLesson }
        
        if lessonsCoreData.count < 4 {
            return Lesson.defaultArratOfLesson
        }
        
        var lessonsFromCoreData: [Lesson] = []
        
        lessonsFromCoreData.append(contentsOf: lessonsCoreData.map({
            $0.wrappedLesson
        }))
        
        let (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getCurrentWeekAndDayNumber()
        
        let (firstNextLessonID, secondNextLessonID, thirdNextLessonID) = getNextThreeLessonsID(lessons: lessonsFromCoreData, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
        
        var arrayWithLessonsToShow: [Lesson] = []
        if let firstLesson = lessonsFromCoreData.first(where: { return $0.id == firstNextLessonID }),
           let secondLesson = lessonsFromCoreData.first(where: { return $0.id == secondNextLessonID }),
           let thirdLesson = lessonsFromCoreData.first(where: { return $0.id == thirdNextLessonID }){
            arrayWithLessonsToShow = [firstLesson, secondLesson, thirdLesson]
        }
        return arrayWithLessonsToShow
    }
    
    func makeTimeLine1(arrayWithLessonsToShow: inout [Lesson], dayNumberFromCurrentDate: Int, currentWeekFromTodayDate: WeekType) -> (entries: [LessonsEntry], dateToUpdate: Date) {

        var dateToUpdate = Date.tomorrow
        
        /// Update timeline options
        var entries = [LessonsEntry(date: Date(), lessons: arrayWithLessonsToShow)]
        
        if arrayWithLessonsToShow[0].dayNumber == dayNumberFromCurrentDate {
            
            entries.append(LessonsEntry(date: getDateStartAndEnd(of: arrayWithLessonsToShow[0]).dateStart, lessons: arrayWithLessonsToShow))
            
            
            dateToUpdate = getDateStartAndEnd(of: arrayWithLessonsToShow[0]).dateEnd

            /// Remove lesson which end
            arrayWithLessonsToShow.remove(at: 0)
            
            /// New entry without lesson which end. This entry presented when widget if waiting for reloading timeline.
            entries.append(LessonsEntry(date: dateToUpdate, lessons: arrayWithLessonsToShow))
            
            entries.append(LessonsEntry(date: getDateStartAndEnd(of: arrayWithLessonsToShow[0]).dateStart, lessons: arrayWithLessonsToShow))
        }
        
        
        return (entries: entries, dateToUpdate: dateToUpdate)
    }
}


struct LessonsEntry: TimelineEntry {
    public let date: Date
    public let lessons: [Lesson]
}


struct KpiRozkladWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    @Environment(\.redactionReasons) var redactionReasons
    
    var entry: Provider.Entry

    init (entry: Provider.Entry) {
        self.entry = entry
    }
    
    
    @ViewBuilder
    var body: some View {
        
        switch family {
        case .systemSmall:
            WidgetViewSmall(lessons: entry.lessons, date: entry.date)
                .redacted(reason: redactionReasons)

        case .systemMedium:
             WidgetViewMedium(lessons: entry.lessons, date: entry.date)
                .redacted(reason: redactionReasons)

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
                            provider: Provider(context: persistentContainer.viewContext)) { entry in
            KpiRozkladWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Віджет Kpi Rozklad")
        .description("Актуальний розклад для вас")
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
