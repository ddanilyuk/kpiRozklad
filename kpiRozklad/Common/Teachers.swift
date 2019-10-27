//
//  Teachers.swift
//  kpiRozklad
//
//  Created by Denis on 27.10.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let teachers = try? newJSONDecoder().decode(Teachers.self, from: jsonData)

import Foundation

// MARK: - Teachers
struct Teachers: Codable {
    let statusCode, timeStamp: Int
    let message: String
    let debugInfo: JSONNull?
    let meta: Meta
    let data: [DatumTeachers]
}

// MARK: - Datum
struct DatumTeachers: Codable {
    let teacherID, teacherName, teacherFullName, teacherShortName: String
    let teacherURL: String
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

// MARK: - Meta
struct Meta: Codable {
    let totalCount: String
    let offset, limit: Int

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case offset, limit
    }
}

