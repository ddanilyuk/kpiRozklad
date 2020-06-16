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
func fetchingCoreData(managedContext: NSManagedObjectContext) -> [Lesson] {
        
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LessonData")

    var lessonsArray: [Lesson] = []
    do {
        guard let fetchResult = try managedContext.fetch(fetchRequest) as? [LessonData] else { return [] }

        for lessonData in fetchResult {
            
            var roomsArray: [Room] = []
            let room: Room?
            
            if let roomData = lessonData.roomsRelationship {
                room = Room(roomID: roomData.roomID ?? "",
                            roomName: roomData.roomName ?? "",
                            roomLatitude: roomData.roomLatitude ?? "",
                            roomLongitude: roomData.roomLongitude ?? "")
                
                if let room = room {
                    roomsArray.append(room)
                }
            }
            
            
            var teachersArray: [Teacher] = []
            let teacher: Teacher?
            
            if let teacherData = lessonData.teachersRelationship {
                teacher = Teacher(teacherID: teacherData.teacherID ?? "",
                                  teacherName: teacherData.teacherName ?? "",
                                  teacherFullName: teacherData.teacherFullName ?? "",
                                  teacherShortName: teacherData.teacherShortName ?? "",
                                  teacherURL: teacherData.teacherURL ?? "",
                                  teacherRating: teacherData.teacherRating ?? "")
                
                if let teacher = teacher {
                    teachersArray.append(teacher)
                }
            }
        
            
            var groupsArray: [Group] = []

            if let groupsDataArray = lessonData.groupsRelationship?.allObjects as? [GroupData] {
                for groupData in groupsDataArray {
                    let group = Group(groupID: Int(groupData.groupID),
                                      groupFullName: groupData.groupFullName ?? "",
                                      groupPrefix: groupData.groupFullName ?? "",
                                      groupOkr: GroupOkr(rawValue: groupData.groupOkr ?? "") ?? GroupOkr.bachelor,
                                      groupType: GroupType(rawValue: groupData.groupType ?? "") ?? GroupType.daily,
                                      groupURL: groupData.groupURL ?? "")
                    
                    groupsArray.append(group)
                }
            }
            
            
            let lesson = Lesson(lessonID: lessonData.lessonID ?? "",
                                dayNumber: lessonData.dayNumber ?? "",
                                groupID: lessonData.groupID ?? "",
                                dayName: DayName(rawValue: lessonData.dayName ?? "") ?? DayName.mounday,
                                lessonName: lessonData.lessonName ?? "",
                                lessonFullName: lessonData.lessonFullName ?? "",
                                lessonNumber: lessonData.lessonNumber ?? "",
                                lessonRoom: lessonData.lessonRoom ?? "",
                                lessonType: LessonType(rawValue: lessonData.lessonType ?? "") ?? LessonType.empty,
                                teacherName: lessonData.teacherName ?? "",
                                lessonWeek: lessonData.lessonWeek ?? "",
                                timeStart: lessonData.timeStart ?? "",
                                timeEnd: lessonData.timeEnd ?? "",
                                rate: lessonData.rate ?? "",
                                teachers: teachersArray,
                                rooms: roomsArray,
                                groups: groupsArray)
            
            lessonsArray.append(lesson)
        }
    } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
    }
    
    return lessonsArray
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

            lessonData.dayName = lesson.dayName.rawValue
            lessonData.dayNumber = lesson.dayNumber
            lessonData.groupID = lesson.groupID
            lessonData.lessonFullName = lesson.lessonFullName
            lessonData.lessonID = lesson.lessonID
            lessonData.lessonName = lesson.lessonName
            lessonData.lessonNumber = lesson.lessonNumber
            lessonData.lessonRoom = lesson.lessonRoom
            lessonData.lessonType = lesson.lessonType.rawValue
            lessonData.lessonWeek = lesson.lessonWeek
            lessonData.rate = lesson.rate
            lessonData.dayName = lesson.dayName.rawValue
            lessonData.teacherName = lesson.teacherName
            lessonData.timeEnd = lesson.timeEnd
            lessonData.timeStart = lesson.timeStart
            
            
            let roomData = RoomsData(context: managedContext)
            
            if lesson.rooms.count != 0 {
                roomData.roomID = lesson.rooms[0].roomID
                roomData.roomLatitude = lesson.rooms[0].roomLatitude
                roomData.roomLongitude = lesson.rooms[0].roomLongitude
                roomData.roomName = lesson.rooms[0].roomName
            }
            
            
            let teacherData = TeachersData(context: managedContext)

            if lesson.teachers?.count != 0 {
                teacherData.teacherFullName = lesson.teachers?[0].teacherFullName
                teacherData.teacherID = lesson.teachers?[0].teacherID
                teacherData.teacherName = lesson.teachers?[0].teacherName
                teacherData.teacherRating = lesson.teachers?[0].teacherRating
                teacherData.teacherShortName = lesson.teachers?[0].teacherShortName
                teacherData.teacherURL = lesson.teachers?[0].teacherURL
            }
            
            
            var array: [GroupData] = []
            
            for group in lesson.groups ?? [] {
                let groupData = GroupData(context: managedContext)
                groupData.groupFullName = group.groupFullName
                groupData.groupID = Int32(group.groupID)
                groupData.groupOkr = group.groupOkr.rawValue
                groupData.groupPrefix = group.groupPrefix
                groupData.groupType = group.groupType.rawValue
                groupData.groupURL = group.groupURL
                array.append(groupData)
            }
        
            
            lessonData.roomsRelationship = roomData
            lessonData.teachersRelationship = teacherData
            lessonData.groupsRelationship = NSSet(array: array)
            

            do {
                try managedContext.save()
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
