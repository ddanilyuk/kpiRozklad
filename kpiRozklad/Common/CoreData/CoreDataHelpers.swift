//
//  CoreDataHelpers.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 30.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit
import CoreData


/**
 Function which fetch lesson from core data
 
 - Note: Core Data for entity "Lesson"

 - Returns: Lessons from Core Data
 */
//func fetchingCoreData(managedContext: NSManagedObjectContext) -> [Lesson] {
//        
//    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LessonData")
//
//    var lessonsArray: [Lesson] = []
//    do {
//        guard let fetchResult = try managedContext.fetch(fetchRequest) as? [LessonData] else { return [] }
//
//        for lessonData in fetchResult {
//            
//            var roomsArray: [Room] = []
//            let room: Room?
//            
//            if let roomData = lessonData.roomsRelationship {
//                room = Room(roomID: roomData.roomID ?? "",
//                            roomName: roomData.roomName ?? "",
//                            roomLatitude: roomData.roomLatitude ?? "",
//                            roomLongitude: roomData.roomLongitude ?? "")
//                
//                if let room = room {
//                    roomsArray.append(room)
//                }
//            }
//            
//            
//            var teachersArray: [Teacher] = []
//            let teacher: Teacher?
//            
//            if let teacherData = lessonData.teachersRelationship {
//                teacher = Teacher(teacherID: teacherData.teacherID ?? "",
//                                  teacherName: teacherData.teacherName ?? "",
//                                  teacherFullName: teacherData.teacherFullName ?? "",
//                                  teacherShortName: teacherData.teacherShortName ?? "",
//                                  teacherURL: teacherData.teacherURL ?? "",
//                                  teacherRating: teacherData.teacherRating ?? "")
//                
//                if let teacher = teacher {
//                    teachersArray.append(teacher)
//                }
//            }
//        
//            
//            var groupsArray: [Group] = []
//
//            if let groupsDataArray = lessonData.groupsRelationship?.allObjects as? [GroupData] {
//                for groupData in groupsDataArray {
//                    let group = Group(groupID: Int(groupData.groupID),
//                                      groupFullName: groupData.groupFullName ?? "",
//                                      groupPrefix: groupData.groupFullName ?? "",
//                                      groupOkr: GroupOkr(rawValue: groupData.groupOkr ?? "") ?? GroupOkr.bachelor,
//                                      groupType: GroupType(rawValue: groupData.groupType ?? "") ?? GroupType.daily,
//                                      groupURL: groupData.groupURL ?? "")
//                    
//                    groupsArray.append(group)
//                }
//            }
//            
//            
//            let lesson = Lesson(id: lessonData.id ?? "",
//                                dayNumber: lessonData.dayNumber ?? "",
//                                groupID: lessonData.groupID ?? "",
//                                dayName: DayName(rawValue: lessonData.dayName ?? "") ?? DayName.mounday,
//                                lessonName: lessonData.lessonName ?? "",
//                                lessonFullName: lessonData.lessonFullName ?? "",
//                                lessonNumber: lessonData.lessonNumber ?? "",
//                                lessonRoom: lessonData.lessonRoom ?? "",
//                                lessonType: LessonType(rawValue: lessonData.lessonType ?? "") ?? LessonType.empty,
//                                teacherName: lessonData.teacherName ?? "",
//                                lessonWeek: lessonData.lessonWeek ?? "",
//                                timeStart: lessonData.timeStart ?? "",
//                                timeEnd: lessonData.timeEnd ?? "",
//                                rate: lessonData.rate ?? "",
//                                teachers: teachersArray,
//                                rooms: roomsArray,
//                                groups: groupsArray)
//            
//            lessonsArray.append(lesson)
//        }
//    } catch let error as NSError {
//        print("Could not save. \(error), \(error.userInfo)")
//    }
//    
//    return lessonsArray
//}


func fetchingCoreData(managedContext: NSManagedObjectContext) -> [Lesson] {
    guard let lessonsCoreData = try? managedContext.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "LessonData")) as? [LessonData] else { return Lesson.defaultArratOfLesson }
    
    var lessonsFromCoreData: [Lesson] = []
    
    lessonsFromCoreData.append(contentsOf: lessonsCoreData.map({
        $0.wrappedLesson
    }))
    
    return lessonsFromCoreData
}


/**
Function which save all data from server in to Core data
 
 - Note: Core Data for entity "Lesson"
 
 - Parameter vc: Shedule VC to call `makeLessonsShedule()`
 - Parameter datum: array of  [Lesson] which received from server
*/
func updateCoreData(lessons:  [Lesson], managedContext: NSManagedObjectContext, complition: @escaping () -> ()) {
    
    DispatchQueue.main.async {
        /// Delete all
        deleteAllFromCoreData(managedContext: managedContext)

        for lesson in lessons {
            let lessonData = LessonData(context: managedContext)
            
            
    //        let lesson = lessonData.wrappedLesson

            lessonData.dayName = lesson.dayName.rawValue
            lessonData.dayNumber = Int32(lesson.dayNumber)
            lessonData.groupID = Int32(lesson.groupID ?? 0)
            lessonData.lessonFullName = lesson.lessonFullName
            lessonData.id = Int32(lesson.id)
            lessonData.lessonName = lesson.lessonName
            lessonData.lessonNumber = Int32(lesson.lessonNumber)
            lessonData.lessonRoom = lesson.lessonRoom
            lessonData.lessonType = lesson.lessonType.rawValue
            lessonData.lessonWeek = Int32(lesson.lessonWeek.rawValue) ?? 1
            lessonData.rate = lesson.rate
            lessonData.dayName = lesson.dayName.rawValue
            lessonData.teacherName = lesson.teacherName
            lessonData.timeEnd = lesson.timeEnd
            lessonData.timeStart = lesson.timeStart
    //
            
            let roomData = RoomsData(context: managedContext)
            
            roomData.roomID = Int32(lesson.room?.roomID ?? 0)
            roomData.roomLatitude = lesson.room?.roomLatitude
            roomData.roomLongitude = lesson.room?.roomLongitude
            roomData.roomName = lesson.room?.roomName
            
            
            let teacherData = TeachersData(context: managedContext)

            teacherData.teacherFullName = lesson.teacher?.teacherFullName
            teacherData.teacherID = Int32(lesson.teacher?.teacherID ?? 0)
            teacherData.teacherName = lesson.teacher?.teacherName
            teacherData.teacherRating = lesson.teacher?.teacherRating
            teacherData.teacherShortName = lesson.teacher?.teacherShortName
            teacherData.teacherURL = lesson.teacher?.teacherURL
            
            
            var array: [GroupData] = []
            
            for group in lesson.groups ?? [] {
                let groupData = GroupData(context: managedContext)
                groupData.groupFullName = group?.groupFullName
                groupData.groupID = Int32(group?.groupID ?? 0)
                groupData.groupOkr = group?.groupOkr.rawValue
                groupData.groupPrefix = group?.groupPrefix
                groupData.groupType = group?.groupType.rawValue
                groupData.groupURL = group?.groupURL
                array.append(groupData)
            }
        
            lessonData.roomsRelationship = roomData
            lessonData.teachersRelationship = teacherData
            lessonData.addToGroupsRelationship(NSSet(array: array))

            do {
                if managedContext.hasChanges {
                    try managedContext.save()
                }
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        complition()
    }
    
    
}


/**
 Function that clear Core Data
 
 - Note: Core Data for entity "Lesson"
 */
func deleteAllFromCoreData(managedContext: NSManagedObjectContext) {
//    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LessonData")

    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LessonData")
    

    // Configure Fetch Request
    fetchRequest.includesPropertyValues = false

    do {

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
