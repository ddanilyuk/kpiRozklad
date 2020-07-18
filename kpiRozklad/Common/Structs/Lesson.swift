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
public struct Lesson: Codable, Hashable, Identifiable {
    public let id: Int
    let dayNumber, lessonNumber: Int
    let lessonWeek: WeekType
    let groupID: Int?
    let dayName: DayName
    let lessonType: LessonType
    let lessonName, lessonFullName, lessonRoom: String
    let teacherName, timeStart, timeEnd: String
    let rate: String
    let teacher: Teacher?
    let room: Room?
    let groups: [Group?]?
        
    enum CodingKeys: String, CodingKey {
        case id = "lesson_id"
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
        case room = "rooms"
        case teacher = "teachers"

        case rate, groups
    }
    
    static let defaultLesson = Lesson(id: 1,
                                      dayNumber: 1,
                                      lessonNumber: 12,
                                      lessonWeek: WeekType.first,
                                      groupID: 123,
                                      dayName: DayName.mounday,
                                      lessonType: LessonType.лек1,
                                      lessonName: "Назва предмету",
                                      lessonFullName: "Повна назва предмету",
                                      lessonRoom: "301-18",
                                      teacherName: "ст. вик. Викладач",
                                      timeStart: "08:30", timeEnd: "10:25",
                                      rate: "1.123",
                                      teacher: Teacher(teacherID: 1,
                                                       teacherURL: "url",
                                                       teacherName: "Викладач Петро Петрович",
                                                       teacherFullName: "старший викладач Викладач Петро Петрович",
                                                       teacherShortName: "Викладач Петро Петрович",
                                                       teacherRating: "1.123"),
                                      room: Room(roomID: 1,
                                                 roomName: "301-18",
                                                 roomLatitude: "1.123",
                                                 roomLongitude: "1.123"),
                                      groups: nil)
    
    static var defaultArratOfLesson: [Lesson] = Array(repeating: defaultLesson, count: 4)
}

#if os(iOS)
extension Lesson {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Strings
        lessonName = try values.decode(String.self, forKey: .lessonName)
        lessonFullName = try values.decode(String.self, forKey: .lessonFullName)
        lessonRoom = try values.decode(String.self, forKey: .lessonRoom)
        teacherName = try values.decode(String.self, forKey: .teacherName)
        timeStart = try values.decode(String.self, forKey: .timeStart)
        timeEnd = try values.decode(String.self, forKey: .timeEnd)
        rate = try values.decode(String.self, forKey: .rate)
        
        // Enums
        dayName = try values.decode(DayName.self, forKey: .dayName)
        lessonType = try values.decode(LessonType.self, forKey: .lessonType)
        lessonWeek = try values.decode(WeekType.self, forKey: .lessonWeek)

        // Strings To Int
        guard let idCasted = try Int(values.decode(String.self, forKey: .id)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.id], debugDescription: "Expecting string representation of Int"))
        }
        id = idCasted
        
        if let dayNumberCasted = try Int(values.decode(String.self, forKey: .dayNumber)) {
            dayNumber = dayNumberCasted
        } else {
            dayNumber = 1
        }
        
        if let lessonNumberCasted = try Int(values.decode(String.self, forKey: .lessonNumber)) {
            lessonNumber = lessonNumberCasted
        } else {
            lessonNumber = 1
        }
        
        if let groupIDCasted = try? Int(values.decode(String.self, forKey: .groupID)) {
            groupID = groupIDCasted
        } else {
            groupID = 0
        }
        
        // Other types
        
        teacher = try values.decode([Teacher?].self, forKey: .teacher).first as? Teacher ?? nil
        room = try values.decode([Room?].self, forKey: .room).first as? Room ?? nil
        groups = try? values.decode([Group?]?.self, forKey: .groups) ?? []
    }
    
    public init(from2 decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Strings
        lessonName = try values.decode(String.self, forKey: .lessonName)
        lessonFullName = try values.decode(String.self, forKey: .lessonFullName)
        lessonRoom = try values.decode(String.self, forKey: .lessonRoom)
        teacherName = try values.decode(String.self, forKey: .teacherName)
        timeStart = try values.decode(String.self, forKey: .timeStart)
        timeEnd = try values.decode(String.self, forKey: .timeEnd)
        rate = try values.decode(String.self, forKey: .rate)
        
        // Enums
        dayName = try values.decode(DayName.self, forKey: .dayName)
        lessonType = try values.decode(LessonType.self, forKey: .lessonType)
        lessonWeek = try values.decode(WeekType.self, forKey: .lessonWeek)

        // Strings To Int
//        guard let idCasted = try Int(values.decode(String.self, forKey: .id)) else {
//            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.id], debugDescription: "Expecting string representation of Int"))
//        }
        id = try values.decode(Int.self, forKey: .id)

        
        if let dayNumberCasted = try Int(values.decode(String.self, forKey: .dayNumber)) {
            dayNumber = dayNumberCasted
        } else {
            dayNumber = 1
        }
        
        if let lessonNumberCasted = try Int(values.decode(String.self, forKey: .lessonNumber)) {
            lessonNumber = lessonNumberCasted
        } else {
            lessonNumber = 1
        }
        
        if let groupIDCasted = try? Int(values.decode(String.self, forKey: .groupID)) {
            groupID = groupIDCasted
        } else {
            groupID = 0
        }
        
        // Other types
        
        teacher = try values.decode([Teacher?].self, forKey: .teacher).first as? Teacher ?? nil
        room = try values.decode([Room?].self, forKey: .room).first as? Room ?? nil
        groups = try? values.decode([Group?]?.self, forKey: .groups) ?? []
    }

    
}
#endif


extension Lesson: Comparable {
    public static func < (lhs: Lesson, rhs: Lesson) -> Bool {
        if lhs.lessonWeek != rhs.lessonWeek {
            return lhs.lessonWeek < rhs.lessonWeek
        } else if lhs.dayNumber != rhs.dayNumber {
            return lhs.dayNumber < rhs.dayNumber
        } else {
            return lhs.lessonNumber < rhs.lessonNumber
        }
    }
    
    public static func == (lhs: Lesson, rhs: Lesson) -> Bool {
        return lhs.id == rhs.id
    }
}
