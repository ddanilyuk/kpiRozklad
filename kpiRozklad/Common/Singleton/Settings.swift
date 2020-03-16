//
//  Settings.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 09.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

class Settings {
    private let userDefaults = UserDefaults.standard
     
    static let shared = Settings()
     
    var isTryToRefreshShedule: Bool {
        get {
            return userDefaults.bool(forKey: "isTryToRefreshShedule")
        }
        set {
            userDefaults.set(newValue, forKey: "isTryToRefreshShedule")
        }
    }
    
    var isTryToReloadTableView: Bool {
        get {
            return userDefaults.bool(forKey: "isTryToReloadTableView")
        }
        set {
            userDefaults.set(newValue, forKey: "isTryToReloadTableView")
        }
    }
    
    var groupName: String {
        get {
            return userDefaults.string(forKey: "groupName") ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: "groupName")
        }
    }
    
    var groupID: Int {
        get {
            return userDefaults.integer(forKey: "groupID")
        }
        set {
            userDefaults.set(newValue, forKey: "groupID")
        }
    }
    
    var teacherName: String {
        get {
            return userDefaults.string(forKey: "teacherName") ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: "teacherName")
        }
    }
    
    var teacherID: Int {
        get {
            return userDefaults.integer(forKey: "teacherID")
        }
        set {
            userDefaults.set(newValue, forKey: "teacherID")
        }
    }
    
    var sheduleUpdateTime: String {
        get {
            return userDefaults.string(forKey: "sheduleUpdateTime") ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: "sheduleUpdateTime")
        }
    }
    
    
    var updateAtOnceFirst: String {
        get {
            return userDefaults.string(forKey: "updateAtOnceFirst") ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: "updateAtOnceFirst")
        }
    }
    
    var updateAtOnce: String {
        get {
            return userDefaults.string(forKey: "updateAtOnce") ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: "updateAtOnce")
        }
    }
    
    var updateAtOnceSecond: String {
        get {
            return userDefaults.string(forKey: "updateAtOnceSecond") ?? ""
        }
        set {
            userDefaults.set(newValue, forKey: "updateAtOnceSecond")
        }
    }
    
    var isShowGreetings: Bool {
        get {
            return userDefaults.bool(forKey: "isShowGreetings")
        }
        set {
            userDefaults.set(newValue, forKey: "isShowGreetings")
        }
    }
    
    var isGroupsShedule: Bool {
        get {
            return userDefaults.bool(forKey: "isGroupsShedule")
        }
        set {
            userDefaults.set(newValue, forKey: "isGroupsShedule")
        }
    }
    
    var isTeacherShedule: Bool {
        get {
            return userDefaults.bool(forKey: "isTeacherShedule")
        }
        set {
            userDefaults.set(newValue, forKey: "isTeacherShedule")
        }
    }
    
    var cellColour: UIColor {
        get {
            let color = NSKeyedUnarchiver.unarchiveObject(with: userDefaults.data(forKey: "cellColour") ?? Data()) as? UIColor
            return color ?? UIColor.black
        }
        
        set {
            var colorData: NSData?
            do {
                colorData = try NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false) as NSData?
            } catch {
                
            }

            userDefaults.set(colorData, forKey: "cellColour")
            
        }
    }
 }
