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

import Foundation

// MARK: - Welcome
struct WelcomeLessons: Codable {
    let statusCode, timeStamp: Int
    let message, debugInfo: String
    let meta: JSONNull?
    let data: [Lesson]
}

// MARK: - Lesson
struct Lesson: Codable {
    let lessonID, groupID, dayNumber: String
    let dayName: DayName
    let lessonName, lessonFullName, lessonNumber, lessonRoom: String
    let lessonType: LessonType
    let teacherName, lessonWeek, timeStart, timeEnd: String
    let rate: String
    let teachers: [Teacher]
    let rooms: [Room]

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
        case rate, teachers, rooms
    }
}

enum DayName: String, Codable {
    case вівторок = "Вівторок"
    case пЯтниця = "П’ятниця"
    case понеділок = "Понеділок"
    case середа = "Середа"
    case четвер = "Четвер"
}

enum LessonType: String, Codable {
    case empty = ""
    case лаб = "Лаб"
    case лек = "Лек"
    case прак = "Прак"
}

// MARK: - Room
struct Room: Codable {
    let roomID, roomName, roomLatitude, roomLongitude: String

    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case roomName = "room_name"
        case roomLatitude = "room_latitude"
        case roomLongitude = "room_longitude"
    }
}

// MARK: - Teacher
//struct Teacher: Codable {
//    let teacherID, teacherName, teacherFullName, teacherShortName: String
//    let teacherURL: String
//    let teacherRating: String
//
//    enum CodingKeys: String, CodingKey {
//        case teacherID = "teacher_id"
//        case teacherName = "teacher_name"
//        case teacherFullName = "teacher_full_name"
//        case teacherShortName = "teacher_short_name"
//        case teacherURL = "teacher_url"
//        case teacherRating = "teacher_rating"
//    }
//}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
