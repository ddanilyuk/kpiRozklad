//
//  Group.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 11.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import Foundation


// MARK: - Datum
public struct Group: Codable, Hashable {
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

extension Group {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Strings
        groupFullName = try values.decode(String.self, forKey: .groupFullName)
        groupPrefix = try values.decode(String.self, forKey: .groupPrefix)
        groupURL = try values.decode(String.self, forKey: .groupURL)

        // Enums
        groupOkr = try values.decode(GroupOkr.self, forKey: .groupOkr)
        groupType = try values.decode(GroupType.self, forKey: .groupType)

//        guard let idCasted = try Int(values.decode(Int.self, forKey: .groupID)) else {
//            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.groupID], debugDescription: "Expecting string representation of Int"))
//        }
        groupID = try values.decode(Int.self, forKey: .groupID)
    }
}


public enum GroupOkr: String, Codable, Hashable {
    case bachelor = "bachelor"
    case magister = "magister"
}


public enum GroupType: String, Codable, Hashable {
    case daily = "daily"
    case extramural = "extramural"
}

