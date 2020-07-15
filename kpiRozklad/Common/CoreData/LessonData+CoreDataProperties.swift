//
//  LessonData+CoreDataProperties.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 05.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//
//

import Foundation
import CoreData


extension LessonData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LessonData> {
        return NSFetchRequest<LessonData>(entityName: "LessonData")
    }

    @NSManaged public var dayName: String?
    @NSManaged public var dayNumber: Int32
    @NSManaged public var groupID: Int32
    @NSManaged public var lessonFullName: String?
    @NSManaged public var id: Int32
    @NSManaged public var lessonName: String?
    @NSManaged public var lessonNumber: Int32
    @NSManaged public var lessonRoom: String?
    @NSManaged public var lessonType: String?
    @NSManaged public var lessonWeek: Int32
    @NSManaged public var rate: String?
    @NSManaged public var teacherName: String?
    @NSManaged public var timeEnd: String?
    @NSManaged public var timeStart: String?
    @NSManaged public var groupsRelationship: NSSet?
    @NSManaged public var roomsRelationship: RoomsData?
    @NSManaged public var teachersRelationship: TeachersData?
    
    public var wrappedGroups: [Group] {
        let set = groupsRelationship as? Set<Group> ?? []
        return set.sorted {
            $0.groupFullName < $1.groupFullName
        }
    }
    
    public var wrappedLesson: Lesson {
        Lesson(id: Int(id), dayNumber: Int(dayNumber), lessonNumber: Int(lessonNumber), lessonWeek: WeekType(rawValue: String(lessonWeek)) ?? .first, groupID: Int(groupID), dayName: DayName(rawValue: dayName ?? "Понеділок") ?? .mounday, lessonType: LessonType(rawValue: lessonType ?? "") ?? .empty, lessonName: lessonName ?? "", lessonFullName: lessonFullName ?? "", lessonRoom: lessonRoom ?? "", teacherName: teacherName ?? "", timeStart: timeStart ?? "", timeEnd: timeEnd ?? "", rate: rate ?? "", teacher: teachersRelationship?.wrappedTeacher, room: roomsRelationship?.wrappedRoom, groups: wrappedGroups)
    }

}

// MARK: Generated accessors for groupsRelationship
extension LessonData {

    @objc(addGroupsRelationshipObject:)
    @NSManaged public func addToGroupsRelationship(_ value: GroupData)

    @objc(removeGroupsRelationshipObject:)
    @NSManaged public func removeFromGroupsRelationship(_ value: GroupData)

    @objc(addGroupsRelationship:)
    @NSManaged public func addToGroupsRelationship(_ values: NSSet)

    @objc(removeGroupsRelationship:)
    @NSManaged public func removeFromGroupsRelationship(_ values: NSSet)

}
