//
//  Room.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 13.06.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


struct Room: Codable {
    let roomID, roomName, roomLatitude, roomLongitude: String

    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case roomName = "room_name"
        case roomLatitude = "room_latitude"
        case roomLongitude = "room_longitude"
    }
}
