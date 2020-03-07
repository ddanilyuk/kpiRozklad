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

    do {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LessonData")
        let res = try managedContext.fetch(fetchRequest)
        print(res.count)
        for some in res {
            
            let obj = some as! LessonData
            print(obj.lessonNumber, obj.dayName)
            let allObjects = obj.groupsRelationship?.allObjects as! [GroupData]
            print(allObjects.count)
            for s in allObjects {
                
                if let groupFullName = s.groupFullName, let groupURL = s.groupURL {
                    print(groupFullName)
                    print(groupURL)
                }
            }
            
            print("-----")

        }


        

    } catch {

    }

    
    var lessons: [Lesson] = []
    
    /// Getting all data from Core Data to [Lesson] struct
    do {
        let lessonsCoreData = try managedContext.fetch(fetchRequest)
        lessons = []
        
        

        
        for lesson in lessonsCoreData {
            
//            let lessonLesson: LessonData? = lessonsCoreData as? LessonData
//            print(lessonLesson?.groupID)
//            print(lessonLesson?.groupsRelationship as? NSSet)
//
//            print(lesson.value(forKey: "groupsRelationship") as? NSSet)
//            print(lessonLesson)
            
            guard let lessonID = lesson.value(forKey: "lessonID") as? String,
                
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
                
            let groupID = lesson.value(forKey: "groupID") as? String ?? ""
            
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
                    let roomLongitude = roomData.roomLongitude else { return [] }

                let room = Room(roomID: roomID, roomName: roomName, roomLatitude: roomLatitude, roomLongitude: roomLongitude)

                rooms.append(room)
            }
            
            var groups: [Group] = []
            
            if let groupsData = lesson.value(forKey: "groupsRelationship") as? NSSet {
//                print(groupsData)
                let groupData = groupsData.value(forKey: "groupFullName")
//                var some = groupsData.makeIterator()
//                print(groupData)
                
                
                
                
                

//                guard let groupID = groupData.groupID as? String,
//                    let groupFullName = groupData.groupFullName,
//                    let groupOkr = groupData.groupOkr,
//                    let groupPrefix = groupData.groupPrefix,
//                    let groupURL = groupData.groupURL,
//                    let groupType = groupData.groupType else { return [] }
//
//                let group = Group(groupID: Int(groupID) ?? 0, groupFullName: groupFullName, groupPrefix: groupPrefix, groupOkr: GroupOkr(rawValue: groupOkr) ?? GroupOkr.bachelor, groupType: GroupType(rawValue: groupType) ?? GroupType.daily, groupURL: groupURL)
//                groups.append(group)
//                for groupData in groupsData {
//                    guard let groupID = groupData.groupID as? String,
//                        let groupFullName = groupData.groupFullName,
//                        let groupOkr = groupData.groupOkr,
//                        let groupPrefix = groupData.groupPrefix,
//                        let groupURL = groupData.groupURL,
//                        let groupType = groupData.groupType else { return [] }
//
//                    let group = Group(groupID: Int(groupID) ?? 0, groupFullName: groupFullName, groupPrefix: groupPrefix, groupOkr: GroupOkr(rawValue: groupOkr) ?? GroupOkr.bachelor, groupType: GroupType(rawValue: groupType) ?? GroupType.daily, groupURL: groupURL)
//                    groups.append(group)
//                }

            }
            
//            print(groups)
            
            /// Creating `Lesson`
            let lesson = Lesson(lessonID: lessonID, dayNumber: dayNumber, groupID: groupID,
                               dayName: dayNameCoreData, lessonName: lessonName, lessonFullName: lessonFullName,
                               lessonNumber: lessonNumber, lessonRoom: lessonRoom, lessonType: lessonTypeCoreData,
                               teacherName: teacherName, lessonWeek: lessonWeek, timeStart: timeStart,
                               timeEnd: timeEnd, rate: rate, teachers: teachers, rooms: rooms, groups: groups)
            
            lessons.append(lesson)
        }
        
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
    }
    
    
    return lessons
}


func fetchingCoreDataV2() -> [Lesson] {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return []}

    let managedContext = appDelegate.persistentContainer.viewContext
    
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

extension NSSet {
  func toArray<T>() -> [T] {
    let array = self.map({ $0 as! T})
    return array
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
            let entity4 = NSEntityDescription.entity(forEntityName: "GroupData", in: managedContext)!


            let lessonCoreData = NSManagedObject(entity: entity, insertInto: managedContext)
            let teacherCoreData = NSManagedObject(entity: entity2, insertInto: managedContext)
            let roomCoreData = NSManagedObject(entity: entity3, insertInto: managedContext)
            let groupCoreData = NSManagedObject(entity: entity4, insertInto: managedContext)
            
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
            
            if lesson.groups?.count != 0 && lesson.groups != nil {
//                var groupsCoreData = groupCoreData.mutableSetValue(forKey: "groupsRelationship")
//                var groupsCoreData: [NSManagedObject] = []
//                var ns = NSSet()
                
//                var teamz = groupCoreData.mutableSetValue(forKey: #keyPath(LessonData.groupsRelationship))
                
                var array: [GroupData] = []

                for group in lesson.groups ?? [] {

                    let groupData = GroupData(context: managedContext)
                    groupData.groupFullName = group.groupFullName
                    groupData.groupURL = group.groupURL
                    array.append(groupData)
//                    ns.adding(groupCoreData)
//                    teamz.add(groupCoreData)
//
//                    print(teamz.count)
                }
                
//                print(ns)
//                print(ns.count)
//
//                print(groupsCoreData)
                
                lessonCoreData.setValue(NSSet(array: array), forKey: "groupsRelationship")
            }
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
        
        /// Fetching and updating `lessonsForTableView` and tableView
        vc.makeLessonsShedule(lessonsInit: nil)
    }
}

func updateCoreDataV2(vc: SheduleViewController, datum:  [Lesson]) {
    DispatchQueue.main.async {
        /// Delete all
        deleteAllFromCoreData()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext
        

        
        for lesson in datum {
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
        
        vc.makeLessonsShedule(lessonsInit: nil)
    }
    
}



//extension Group {
//  func configured(groupID _groupID: String,
//                  groupFullName _groupFullName: String,
//                  groupOkr _groupOkr: String,
//                  groupPrefix _groupPrefix: String,
//                  groupType _groupType: String,
//                  groupURL _groupURL: String,
//                  owner _owner: Group) -> Self {
//    groupID = _groupID
//    groupFullName = _groupFullName
//    groupOkr = GroupOkr(_groupOkr
//    groupPrefix = _groupPrefix
//    groupType = _groupType
//    groupURL = _groupURL
//    return self
//  }
//}
