//
//  WatchKitHelpers.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 25.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import WatchConnectivity
import UIKit


func reloadDataOnAppleWatch() {
    if WCSession.isSupported() {
        let session = WCSession.default
        do {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let settings = Settings.shared
            let lessons = fetchingCoreData(managedContext: managedContext)
            
            let encoder = JSONEncoder.init()
            let dataLessons = try encoder.encode(lessons)
            let groupOrTeacherName = settings.sheduleType == .teachers ? settings.teacherName : settings.groupName
            
            let currentColourData = settings.cellCurrentColour.encode()
            let nextColourData = settings.cellNextColour.encode()
            
            let dictionary: [String: Any] = ["lessons": dataLessons,
                                             "groupOrTeacherName": groupOrTeacherName,
                                             "currentColourData": currentColourData,
                                             "nextColourData": nextColourData]
            
            /// updateApplicationContext is not working on watch os 7
            try session.updateApplicationContext(dictionary)
            
            /*
            session.sendMessage(dictionary, replyHandler: nil) { error in
                print(error.localizedDescription)
            }
            */
            print("Session data sended")
        } catch {
            print("Error: \(error)")
        }
    }
}
