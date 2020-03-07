//
//  Group.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 11.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcomeGroup = try? newJSONDecoder().decode(WelcomeGroup.self, from: jsonData)

import Foundation

// MARK: - WelcomeGroup
struct WelcomeGroup: Codable {
    let statusCode, timeStamp: Int
    let message: String
    let debugInfo: JSONNull?
    let meta: Meta?
    let data: [Group]
}

// MARK: - Datum
struct Group: Codable {
    let groupID: Int
    let groupFullName: String
    let groupPrefix: String
    let groupOkr: GroupOkr
    let groupType: GroupType
    let groupURL: String

    enum CodingKeys: String, CodingKey {
        case groupID = "group_id"
        case groupFullName = "group_full_name"
        case groupPrefix = "group_prefix"
        case groupOkr = "group_okr"
        case groupType = "group_type"
        case groupURL = "group_url"
    }
}
let emptyGroup = Group(groupID: 0, groupFullName: "", groupPrefix: "", groupOkr: .magister, groupType: .daily, groupURL: "")

enum GroupOkr: String, Codable {
    case bachelor = "bachelor"
    case magister = "magister"
}


enum GroupType: String, Codable {
    case daily = "daily"
    case extramural = "extramural"
}
