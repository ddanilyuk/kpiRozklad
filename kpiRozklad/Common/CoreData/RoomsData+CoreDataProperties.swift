//
//  RoomsData+CoreDataProperties.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 05.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//
//

import Foundation
import CoreData


extension RoomsData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoomsData> {
        return NSFetchRequest<RoomsData>(entityName: "RoomsData")
    }

    @NSManaged public var roomID: Int32
    @NSManaged public var roomLatitude: String?
    @NSManaged public var roomLongitude: String?
    @NSManaged public var roomName: String?
    @NSManaged public var roomsRelationship: LessonData?
    
    public var wrappedRoom: Room {
        Room(roomID: Int(roomID), roomName: roomName ?? "", roomLatitude: roomLatitude ?? "", roomLongitude: roomLongitude ?? "")
    }

}
