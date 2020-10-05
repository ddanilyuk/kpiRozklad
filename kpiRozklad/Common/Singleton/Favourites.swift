//
//  Favourites.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 22.02.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


class Favourites {
    
    static let shared = Favourites()
    
    private let userDefaults = UserDefaults.standard
    
    var favouriteGroupsNames: [String] {
        get {
            return userDefaults.array(forKey: "favouriteGroupsNames") as? [String] ?? []
        }
        set {
            userDefaults.set(newValue, forKey: "favouriteGroupsNames")
        }
    }
    
    var favouriteGroupsID: [Int] {
        get {
            return userDefaults.array(forKey: "favouriteGroupsID") as? [Int] ?? []
        }
        set {
            userDefaults.set(newValue, forKey: "favouriteGroupsID")
        }
    }
    
    var favouriteTeachersNames: [String] {
        get {
            return userDefaults.array(forKey: "favouriteTeachersNames") as? [String] ?? []
        }
        set {
            userDefaults.set(newValue, forKey: "favouriteTeachersNames")
        }
    }
    
    var favouriteTeachersID: [Int] {
        get {
            return userDefaults.array(forKey: "favouriteTeachersID") as? [Int] ?? []
        }
        set {
            userDefaults.set(newValue, forKey: "favouriteTeachersID")
        }
    }
    
}
