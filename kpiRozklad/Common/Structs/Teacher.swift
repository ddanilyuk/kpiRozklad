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
struct Teacher: Codable {
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
