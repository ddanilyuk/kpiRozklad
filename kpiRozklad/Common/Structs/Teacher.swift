//
//  Teachers.swift
//  kpiRozklad
//
//  Created by Denis on 27.10.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import Foundation


// MARK: - Teachers
struct WelcomeTeachers: Codable {
    let statusCode, timeStamp: Int
    let message: String
    let debugInfo: JSONNull?
    let meta: Meta?
    let data: [Teacher]
}

// MARK: - Datum
public struct Teacher: Codable, Hashable {
    let teacherID: Int
    let teacherURL, teacherName, teacherFullName, teacherShortName: String
    let teacherRating: String

    enum CodingKeys: String, CodingKey {
        case teacherID = "teacher_id"
        case teacherName = "teacher_name"
        case teacherFullName = "teacher_full_name"
        case teacherShortName = "teacher_short_name"
        case teacherURL = "teacher_url"
        case teacherRating = "teacher_rating"
    }
}

extension Teacher {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Strings
        teacherURL = try values.decode(String.self, forKey: .teacherURL)
        teacherName = try values.decode(String.self, forKey: .teacherName)
        teacherFullName = try values.decode(String.self, forKey: .teacherFullName)
        teacherShortName = try values.decode(String.self, forKey: .teacherShortName)
        teacherRating = try values.decode(String.self, forKey: .teacherRating)
        
        guard let idCasted = try Int(values.decode(String.self, forKey: .teacherID)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.teacherID], debugDescription: "Expecting string representation of Int"))
        }
        teacherID = idCasted
    }
}
