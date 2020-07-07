//
//  kpiRozkladWidget.swift
//  kpiRozkladWidget
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
//        let arrayWithLessonsToShow = getArrayWithNextTwoLessons(dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
//        let entry = LessonsEntry(date: Date(), lessons: arrayWithLessonsToShow)
        
        completion(entry)
    }
    
    func timeline(with context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getTimeAndDayNumAndWeekOfYear()

        let arrayWithLessonsToShow = getArrayWithNextTwoLessons(dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
        
        
        
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
    
    
    func getArrayWithNextTwoLessons(dayNumberFromCurrentDate: Int, currentWeekFromTodayDate: WeekType) -> [Lesson] {
        guard let lessonsCoreData = try? managedObjectContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "LessonData")) as? [LessonData] else { return Lesson.defaultArratOfLesson }
        
        if lessonsCoreData.count < 3 {
            return Lesson.defaultArratOfLesson
        }
        
        var lessonsFromCoreData: [Lesson] = []
        
        lessonsFromCoreData.append(contentsOf: lessonsCoreData.map({
            $0.wrappedLesson
        }))
        
        let (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getTimeAndDayNumAndWeekOfYear()
        let (firstNextLessonID, secondNextLessonID) = getNextTwoLessonsID(lessons: lessonsFromCoreData, dayNumberFromCurrentDate: dayNumberFromCurrentDate, currentWeekFromTodayDate: currentWeekFromTodayDate)
        
        var arrayWithLessonsToShow: [Lesson] = []
        if let firstLesson = lessonsFromCoreData.first(where: { return $0.id == firstNextLessonID }),
           let secondLesson = lessonsFromCoreData.first(where: { return $0.id == secondNextLessonID }) {
            arrayWithLessonsToShow = [firstLesson, secondLesson]
        }
        return arrayWithLessonsToShow
    }
    
    
    func getNextTwoLessonsID(lessons: [Lesson], dayNumberFromCurrentDate: Int, currentWeekFromTodayDate: WeekType) -> (firstNextLessonID: Int, secondNextLessonID: Int) {
        
        // Init values
        var firstNextLessonID: Int = 0
        var secondNextLessonID: Int = 0

        // Current date
        let date = Date()
        
        for lessonIndex in 0..<lessons.count {
            let lesson = lessons[lessonIndex]
            let (currentLessonsDateStart, currentLessonsDateEnd) = getDate(lesson: lesson)
            if (currentLessonsDateStart > date || (currentLessonsDateStart < date && currentLessonsDateEnd > date)) && lesson.lessonWeek == currentWeekFromTodayDate && lesson.dayNumber == dayNumberFromCurrentDate {
                firstNextLessonID = lesson.id
                
                if lessonIndex != lessons.count + 1 {
                    secondNextLessonID = lessons[lessonIndex + 1].id
                } else {
                    secondNextLessonID = lessons[0].id
                }
                
                return (firstNextLessonID: firstNextLessonID, secondNextLessonID: secondNextLessonID)
            }
            
        }
        if firstNextLessonID == 0 && secondNextLessonID == 0 {
            if currentWeekFromTodayDate == .first {
                let firstNextLesson = lessons.first { lesson -> Bool in
                    return lesson.lessonWeek == .second
                }
                if let lesson = firstNextLesson {
                    let index = lessons.firstIndex(of: lesson) ?? 0
                    if index != lessons.count + 1 {
                        return (firstNextLessonID: lessons[index].id, secondNextLessonID: lessons[index + 1].id)
                    }
                    
                }
            } else if currentWeekFromTodayDate == .second {
                if lessons.count > 1 {
                    return (firstNextLessonID: lessons[0].id, secondNextLessonID: lessons[1].id)
                }
            }
        }
        
        return (firstNextLessonID: firstNextLessonID, secondNextLessonID: secondNextLessonID)
            
    }
}


struct LessonsEntry: TimelineEntry {
    public let date: Date
    public let lessons: [Lesson]

}

struct PlaceholderView : View {
    var body: some View {
        WidgetView(lessons: Lesson.defaultArratOfLesson)
    }
}


struct KpiRozkladWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        WidgetView(lessons: entry.lessons)
    }
}

@main
struct kpiRozkladWidget: Widget {
    private let kind: String = "kpiRozkladWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind,
                            provider: Provider(context: persistentContainer.viewContext),
                            placeholder: PlaceholderView()
        ) { entry in
            KpiRozkladWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Kpi Rozklad Widget")
        .description("Widget with your shedule")
        .supportedFamilies([.systemMedium])
    }
    
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSCustomPersistentContainer(name: "kpiRozkladModel")
//        let container = NSPersistentContainer(name: "kpiRozkladData")
//        let storeURL = URL.storeURL(for: "group.ddanilyuk.kpiRozkladSwiftUI", databaseName: "LessonsData")
//        let storeDescription = NSPersistentStoreDescription(url: storeURL)
//        container.persistentStoreDescriptions = [storeDescription]

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
        WidgetView(lessons: Lesson.defaultArratOfLesson)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
