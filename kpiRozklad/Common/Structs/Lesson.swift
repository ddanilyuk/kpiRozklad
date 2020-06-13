//
//  Server.swift
//  kpiRozklad
//
//  Created by Denis on 9/26/19.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import UIKit

 
// MARK: - Welcome
struct WelcomeLessons: Codable {
    let statusCode, timeStamp: Int
    let message, debugInfo: String?
    let meta: JSONNull?
    let data: [Lesson]
}


// MARK: - Lesson
struct Lesson: Codable {
    let lessonID, dayNumber: String
    let groupID: String?
    let dayName: DayName
    let lessonName, lessonFullName, lessonNumber, lessonRoom: String
    let lessonType: LessonType
    let teacherName, lessonWeek, timeStart, timeEnd: String
    let rate: String
    let teachers: [Teacher]?
    let rooms: [Room]
    let groups: [Group]?

    
    enum CodingKeys: String, CodingKey {
        case lessonID = "lesson_id"
        case groupID = "group_id"
        case dayNumber = "day_number"
        case dayName = "day_name"
        case lessonName = "lesson_name"
        case lessonFullName = "lesson_full_name"
        case lessonNumber = "lesson_number"
        case lessonRoom = "lesson_room"
        case lessonType = "lesson_type"
        case teacherName = "teacher_name"
        case lessonWeek = "lesson_week"
        case timeStart = "time_start"
        case timeEnd = "time_end"
        case rate, teachers, rooms, groups
    }


}


extension Lesson: Comparable {
    static func < (lhs: Lesson, rhs: Lesson) -> Bool {
        return lhs.dayName.rawValue == rhs.dayName.rawValue

    }
    
    static func == (lhs: Lesson, rhs: Lesson) -> Bool {
        return lhs.dayName.rawValue < rhs.dayName.rawValue
    }
}
