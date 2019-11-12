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
     
     var isLoggedIn: Bool {
         get {
             return userDefaults.bool(forKey: "isLoggedIn")
         }
         set {
             userDefaults.set(newValue, forKey: "isLoggedIn")
         }
     }
    
    var isTryToRefreshShedule: Bool {
        get {
            return userDefaults.bool(forKey: "isTryToRefreshShedule")
        }
        set {
            userDefaults.set(newValue, forKey: "isTryToRefreshShedule")
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
 }
