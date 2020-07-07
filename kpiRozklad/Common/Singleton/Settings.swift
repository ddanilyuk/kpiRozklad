//
//  Settings.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 09.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

public class Settings {
//    private var userDefaults = UserDefaults.standard
    private var userDefaultsWidget = UserDefaults(suiteName: "group.kpiRozkladWidget") ?? UserDefaults()

     
    static let shared = Settings()
     
    var isTryToRefreshShedule: Bool {
        get {
            return userDefaultsWidget.bool(forKey: "isTryToRefreshShedule")
        }
        set {
            userDefaultsWidget.set(newValue, forKey: "isTryToRefreshShedule")
        }
    }
    
    var groupName: String {
        get {
            return userDefaultsWidget.string(forKey: "groupName") ?? ""
        }
        set {
            userDefaultsWidget.set(newValue, forKey: "groupName")
        }
    }
    
    var groupID: Int {
        get {
            return userDefaultsWidget.integer(forKey: "groupID")
        }
        set {
            userDefaultsWidget.set(newValue, forKey: "groupID")
        }
    }
    
    var teacherName: String {
        get {
            return userDefaultsWidget.string(forKey: "teacherName") ?? ""
        }
        set {
            userDefaultsWidget.set(newValue, forKey: "teacherName")
        }
    }
    
    var teacherID: Int {
        get {
            return userDefaultsWidget.integer(forKey: "teacherID")
        }
        set {
            userDefaultsWidget.set(newValue, forKey: "teacherID")
        }
    }
    
    var sheduleUpdateTime: String {
        get {
            return userDefaultsWidget.string(forKey: "sheduleUpdateTime") ?? ""
        }
        set {
            userDefaultsWidget.set(newValue, forKey: "sheduleUpdateTime")
        }
    }
    
    var updateRozkladAfterVersion106: Bool {
        get {
            return userDefaultsWidget.bool(forKey: "updateRozkladAfterVersion106")
        }
        set {
            userDefaultsWidget.set(newValue, forKey: "updateRozkladAfterVersion106")
        }
    }
    
    var isShowGreetings: Bool {
        get {
            return userDefaultsWidget.bool(forKey: "isShowGreetings")
        }
        set {
            userDefaultsWidget.set(newValue, forKey: "isShowGreetings")
        }
    }
    
    var sheduleType: SheduleType {
        get {
            return userDefaultsWidget.bool(forKey: "isGroupsShedule") ? .groups : .teachers
        }
        set {
            if newValue == .groups {
                userDefaultsWidget.set(true, forKey: "isGroupsShedule")
            } else {
                userDefaultsWidget.set(false, forKey: "isGroupsShedule")
            }
        }
    }
    
    var cellNextColour: UIColor {
        get {
            let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: userDefaultsWidget.data(forKey: "cellNextColour") ?? Data())
                
            return color ?? #colorLiteral(red: 0, green: 0.568627451, blue: 0.9176470588, alpha: 1)
        }
        
        set {
            var colorData: NSData?
            
            do {
                colorData = try NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false) as NSData?
            } catch let error {
                print(error.localizedDescription)
            }
            userDefaultsWidget.set(colorData, forKey: "cellNextColour")
        }
    }
    
    
    var cellCurrentColour: UIColor {
        get {
            let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: userDefaultsWidget.data(forKey: "cellNowColour") ?? Data())

            return color ?? UIColor.orange
        }
        
        set {
            var colorData: NSData?
            do {
                colorData = try NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false) as NSData?
            } catch let error {
                print(error.localizedDescription)
            }

//            userDefaults.set(colorData, forKey: "cellNowColour")
            userDefaultsWidget.set(colorData, forKey: "cellNowColour")
        }
    }
 }
