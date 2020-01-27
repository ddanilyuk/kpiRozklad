//
//  CoreDataHelpers.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 30.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit
import CoreData


// MARK: - fetchingCoreData
/// Function which fetch lesson from core data
func fetchingCoreData() -> [Lesson] {
    /// Core data request
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return []}

    let managedContext = appDelegate.persistentContainer.viewContext

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LessonData")
    
    var lessons: [Lesson] = []
    
    /// Getting all data from Core Data to [Lesson] struct
    do {
        let lessonsCoreData = try managedContext.fetch(fetchRequest)
        lessons = []
        
        for lesson in lessonsCoreData {
            
            guard let lessonID = lesson.value(forKey: "lessonID") as? String,
                let groupID = lesson.value(forKey: "groupID") as? String,
                let dayNumber = lesson.value(forKey: "dayNumber") as? String,
                let dayName = lesson.value(forKey: "dayName") as? String,
                let lessonType = lesson.value(forKey: "lessonType") as? String,
                let lessonName = lesson.value(forKey: "lessonName") as? String,
                let lessonFullName = lesson.value(forKey: "lessonFullName") as? String,
                let lessonNumber = lesson.value(forKey: "lessonNumber") as? String,
                let lessonRoom = lesson.value(forKey: "lessonRoom") as? String,
                let teacherName = lesson.value(forKey: "teacherName") as? String,
                let lessonWeek = lesson.value(forKey: "lessonWeek") as? String,
                let timeStart = lesson.value(forKey: "timeStart") as? String,
                let timeEnd = lesson.value(forKey: "timeEnd") as? String,
                let rate = lesson.value(forKey: "rate") as? String else { return [] }
                
            /// Add data to enum  (maybe can changed)
            let dayNameCoreData = DayName(rawValue: dayName) ?? DayName.mounday
            let lessonTypeCoreData = LessonType(rawValue: lessonType) ?? LessonType.empty
            
            
            /// Array of teacher which added to  variable `lesson` and then added to main variable `lessons`
            var teachers: [Teacher] = []
            
            /// Trying to fetch all Teacher Data from TeacherData entity in teachersRelationship
            if let teacherData = lesson.value(forKey: "teachersRelationship") as? TeachersData {

                guard let teacherId = teacherData.teacherID,
                    let teacherShortName = teacherData.teacherShortName,
                    let teacherFullName = teacherData.teacherFullName,
                    let teacherURL = teacherData.teacherURL,
                    let teacherRating = teacherData.teacherRating else { return []}
                
                let teacher = Teacher(teacherID: teacherId, teacherName: teacherName, teacherFullName: teacherFullName, teacherShortName: teacherShortName, teacherURL: teacherURL, teacherRating: teacherRating)
                
                teachers.append(teacher)
            }
            
            
            /// Array of rooms which added to  variable `lesson` and then added to main variable `lessons`
            var rooms: [Room] = []
            
            if let roomData = lesson.value(forKey: "roomsRelationship") as? RoomsData {

                guard let roomID = roomData.roomID,
                    let roomName = roomData.roomName,
                    let roomLatitude = roomData.roomLatitude,
                    let roomLongitude = roomData.roomLongitude else { return []}

                let room = Room(roomID: roomID, roomName: roomName, roomLatitude: roomLatitude, roomLongitude: roomLongitude)

                rooms.append(room)
            }
            
            /// Creating `Lesson`
            let lesson = Lesson(lessonID: lessonID, dayNumber: dayNumber, groupID: groupID,
                               dayName: dayNameCoreData, lessonName: lessonName, lessonFullName: lessonFullName,
                               lessonNumber: lessonNumber, lessonRoom: lessonRoom, lessonType: lessonTypeCoreData,
                               teacherName: teacherName, lessonWeek: lessonWeek, timeStart: timeStart,
                               timeEnd: timeEnd, rate: rate, teachers: teachers, rooms: rooms, groups: [])
            
            lessons.append(lesson)
        }
        
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    
    return lessons
}



// MARK:- deleteAllFromCoreData
/// Simple function that clear Core Data
func deleteAllFromCoreData() {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LessonData")

    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

    // Configure Fetch Request
    fetchRequest.includesPropertyValues = false

    do {
        let managedContext = appDelegate.persistentContainer.viewContext

        let items = try managedContext.fetch(fetchRequest) as! [NSManagedObject]

        for item in items {
            managedContext.delete(item)
        }

        /// Save Changes
        try managedContext.save()

    } catch {
        print("Could not delete. \(error)")
    }
}


// MARK:- updateCoreData
/// Function which save all data from server in to Core data
/// - note: Core Data for entity "Lesson"
/// - Parameter datum: array of  [Lesson] whitch received from server
func updateCoreData(vc: SheduleViewController, datum:  [Lesson]) {
    DispatchQueue.main.async {
        /// Delete all
        deleteAllFromCoreData()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext

        for lesson in datum {
            let entity = NSEntityDescription.entity(forEntityName: "LessonData", in: managedContext)!
            let entity2 = NSEntityDescription.entity(forEntityName: "TeachersData", in: managedContext)!
            let entity3 = NSEntityDescription.entity(forEntityName: "RoomsData", in: managedContext)!


            let lessonCoreData = NSManagedObject(entity: entity, insertInto: managedContext)
            let teacherCoreData = NSManagedObject(entity: entity2, insertInto: managedContext)
            let roomCoreData = NSManagedObject(entity: entity3, insertInto: managedContext)


            lessonCoreData.setValue(lesson.lessonID, forKeyPath: "lessonID")
            lessonCoreData.setValue(lesson.groupID, forKeyPath: "groupID")
            lessonCoreData.setValue(lesson.dayNumber, forKeyPath: "dayNumber")
            lessonCoreData.setValue(lesson.dayName.rawValue, forKeyPath: "dayName")
            lessonCoreData.setValue(lesson.lessonName, forKeyPath: "lessonName")
            lessonCoreData.setValue(lesson.lessonFullName, forKeyPath: "lessonFullName")
            lessonCoreData.setValue(lesson.lessonNumber, forKeyPath: "lessonNumber")
            lessonCoreData.setValue(lesson.lessonRoom, forKeyPath: "lessonRoom")
            lessonCoreData.setValue(lesson.lessonType.rawValue, forKeyPath: "lessonType")
            lessonCoreData.setValue(lesson.teacherName, forKeyPath: "teacherName")
            lessonCoreData.setValue(lesson.lessonWeek, forKeyPath: "lessonWeek")
            lessonCoreData.setValue(lesson.timeStart, forKeyPath: "timeStart")
            lessonCoreData.setValue(lesson.timeEnd, forKeyPath: "timeEnd")
            lessonCoreData.setValue(lesson.rate, forKeyPath: "rate")
            
            if lesson.teachers?.count != 0 {
                teacherCoreData.setValue(lesson.teachers?[0].teacherFullName, forKey: "teacherFullName")
                teacherCoreData.setValue(lesson.teachers?[0].teacherID, forKey: "teacherID")
                teacherCoreData.setValue(lesson.teachers?[0].teacherName, forKey: "teacherName")
                teacherCoreData.setValue(lesson.teachers?[0].teacherRating, forKey: "teacherRating")
                teacherCoreData.setValue(lesson.teachers?[0].teacherShortName, forKey: "teacherShortName")
                teacherCoreData.setValue(lesson.teachers?[0].teacherURL, forKey: "teacherURL")
                
                lessonCoreData.setValue(teacherCoreData, forKey: "teachersRelationship")
            }
            
            if lesson.rooms.count != 0 {
                roomCoreData.setValue(lesson.rooms[0].roomID, forKey: "roomID")
                roomCoreData.setValue(lesson.rooms[0].roomName, forKey: "roomName")
                roomCoreData.setValue(lesson.rooms[0].roomLatitude, forKey: "roomLatitude")
                roomCoreData.setValue(lesson.rooms[0].roomLongitude, forKey: "roomLongitude")

                lessonCoreData.setValue(roomCoreData, forKey: "roomsRelationship")
            }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
        /// Fetching and updating `lessonsForTableView` and tableView
        vc.makeLessonsShedule()
    }
}
