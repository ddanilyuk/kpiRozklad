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


enum DayName: String, Codable, Comparable {
    case mounday = "Понеділок"
    case tuesday = "Вівторок"
    case wednesday = "Середа"
    case thursday = "Четвер"
    case friday = "П’ятниця"
    case saturday = "Субота"
    

    private var sortOrder: Int {
        switch self {
        case .mounday:
            return 1
        case .tuesday:
            return 2
        case .wednesday:
            return 3
        case .thursday:
            return 4
        case .friday:
            return 5
        case .saturday:
            return 6
        }
    }
    
    static func getDayNameFromNumber(_ number: Int) -> DayName? {
        switch number {
        case 1:
            return .mounday
        case 2:
            return .tuesday
        case 3:
            return .wednesday
        case 4:
            return .thursday
        case 5:
            return .friday
        case 6:
            return .saturday
        default:
            return nil
        }
    }

    static func ==(lhs: DayName, rhs: DayName) -> Bool {
        return lhs.sortOrder == rhs.sortOrder
    }

    static func <(lhs: DayName, rhs: DayName) -> Bool {
       return lhs.sortOrder < rhs.sortOrder
    }
    
}


func getArrayOfDayNames() -> [DayName] {
    let mounday = DayName.mounday
    let tuesday = DayName.tuesday
    let wednesday = DayName.wednesday
    let thursday = DayName.thursday
    let friday = DayName.friday
    let saturday = DayName.saturday

    return [mounday, tuesday, wednesday, thursday, friday, saturday]

}


enum LessonType: String, Codable {
    case empty = ""
    case лаб = "Лаб"
    case лек1 = "Лек"
    case лек2 = "лек"
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


// MARK: - Encode/decode helpers

class JSONNull: Codable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
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
