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
    
    var favourite: [String] {
        get {
            return userDefaults.array(forKey: "favourite") as? [String] ?? [""]
        }
        set {
            userDefaults.set(newValue, forKey: "favourite")
        }
    }
 }