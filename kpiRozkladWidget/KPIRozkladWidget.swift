//
//  KPIRozkladWidget.swift
//  KPIRozkladWidget
//
//  Created by Денис Данилюк on 27.06.2020.
//

import WidgetKit
import SwiftUI
import CoreData


struct LessonsEntry: TimelineEntry {
    let date: Date
    let lessons: [Lesson]
}


struct Provider: TimelineProvider {
    
    var managedObjectContext: NSManagedObjectContext
    
    typealias Entry = LessonsEntry
    
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    func placeholder(in context: Context) -> LessonsEntry {
        return LessonsEntry(date: Date(timeIntervalSince1970: 1601208000), lessons: Lesson.defaultArratOfLesson)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LessonsEntry) -> Void) {
        // This time interval need to show in preview "завтра"
        
        let (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getCurrentWeekAndDayNumber()
        
        let arrayWithLessonsToShow = getArrayWithNextThreeLessons(dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate, managedObjectContext: managedObjectContext, isPreview: true)
        
        var date = Date()
        
        if arrayWithLessonsToShow == Lesson.previewLessons {
            date = Date(timeIntervalSince1970: 1601208000)
        }
        
        let entry = LessonsEntry(date: date, lessons: arrayWithLessonsToShow)
        
        completion(entry)
    }
    
    /**
     LessonsEntry must contain 3 lesson: 2 to show and 1 to use when 1 pair end.
     */
    func getTimeline(in context: Context, completion: @escaping (Timeline<LessonsEntry>) -> Void) {
        
        
        let (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getCurrentWeekAndDayNumber()
        
        var arrayWithLessonsToShow = getArrayWithNextThreeLessons(dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate, managedObjectContext: managedObjectContext)
        
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
        
        completion(Timeline(entries: entries, policy: .after(dateToUpdate)))
    }
    
    /// Fetching core data and getting lessons from `getNextThreeLessonsID()`
    func getArrayWithNextThreeLessons(dayNumberFromCurrentDate: Int, currentWeekFromTodayDate: WeekType, managedObjectContext: NSManagedObjectContext, isPreview: Bool = false) -> [Lesson] {
        guard let lessonsCoreData = try? managedObjectContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "LessonData")) as? [LessonData] else { return isPreview ? Lesson.previewLessons : Lesson.defaultArratOfLesson }
        
        if lessonsCoreData.count < 4 {
            return isPreview ? Lesson.previewLessons : Lesson.defaultArratOfLesson
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

}


struct KpiRozkladWidgetEntryView : View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    @Environment(\.redactionReasons) var redactionReasons
    
    var entry: Provider.Entry

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
    
    let kind: String = "KPIRozkladWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: Provider(context: persistentContainer.viewContext)) { entry in
            KpiRozkladWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Віджет Kpi Rozklad")
        .description("Актуальний розклад для вас.")
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
