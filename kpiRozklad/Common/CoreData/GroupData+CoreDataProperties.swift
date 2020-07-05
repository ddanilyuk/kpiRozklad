//
//  GroupData+CoreDataProperties.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 05.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//
//

import Foundation
import CoreData


extension GroupData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupData> {
        return NSFetchRequest<GroupData>(entityName: "GroupData")
    }

    @NSManaged public var groupFullName: String?
    @NSManaged public var groupID: Int32
    @NSManaged public var groupOkr: String?
    @NSManaged public var groupPrefix: String?
    @NSManaged public var groupType: String?
    @NSManaged public var groupURL: String?
    @NSManaged public var groupsRelationship: LessonData?
    
    
    public var wrappedGroup: Group {
        Group(groupID: Int(groupID), groupFullName: groupFullName ?? "", groupPrefix: groupPrefix ?? "", groupOkr: GroupOkr(rawValue: groupOkr ?? "") ?? .bachelor, groupType: GroupType(rawValue: groupType ?? "") ?? .daily, groupURL: groupURL ?? "")
    }

}
