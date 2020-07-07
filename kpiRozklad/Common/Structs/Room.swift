//
//  Room.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 13.06.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


public struct Room: Codable, Hashable {
    let roomID: Int
    let roomName, roomLatitude, roomLongitude: String

    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case roomName = "room_name"
        case roomLatitude = "room_latitude"
        case roomLongitude = "room_longitude"
    }
}

extension Room {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Strings
        roomName = try values.decode(String.self, forKey: .roomName)
        roomLatitude = try values.decode(String.self, forKey: .roomLatitude)
        roomLongitude = try values.decode(String.self, forKey: .roomLongitude)

        
        guard let idCasted = try Int(values.decode(String.self, forKey: .roomID)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.roomID], debugDescription: "Expecting string representation of Int"))
        }
        roomID = idCasted
    }
}
