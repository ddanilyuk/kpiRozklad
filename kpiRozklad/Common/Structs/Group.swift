//
//  Group.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 11.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import Foundation


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


enum GroupOkr: String, Codable {
    case bachelor = "bachelor"
    case magister = "magister"
}


enum GroupType: String, Codable {
    case daily = "daily"
    case extramural = "extramural"
}
