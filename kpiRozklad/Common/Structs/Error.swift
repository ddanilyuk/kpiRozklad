//
//  Error.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 11.12.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import Foundation

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let error = try? newJSONDecoder().decode(Error.self, from: jsonData)

// MARK: - Error
struct Error: Codable {
    let statusCode, timeStamp: Int
    let message: String
}
