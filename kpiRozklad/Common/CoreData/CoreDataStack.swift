//
//  CoreDataStack.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 11.02.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit
import CoreData

class NSCustomPersistentContainer: NSPersistentContainer {
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.kpiRozkladWidget")
        storeURL = storeURL?.appendingPathComponent("LessonData")
        return storeURL!
    }
}
