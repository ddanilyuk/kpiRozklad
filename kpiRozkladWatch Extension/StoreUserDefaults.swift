//
//  StoreUserDefaults.swift
//  kpiRozkladWatch Extension
//
//  Created by Денис Данилюк on 10.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


public class StoreUserDefaults {
    
    private var userDefaults = UserDefaults.init()

    static let shared = StoreUserDefaults()
    
    var lessons: [Lesson] {
        get {
            let decoder = JSONDecoder.init()
            let data = userDefaults.data(forKey: "lessons") ?? Data()
            let lessons = try? decoder.decode([Lesson].self, from: data)
                
            return lessons ?? []
        }
        
        set {
            let encoder = JSONEncoder.init()

            let data = try? encoder.encode(newValue)
            
            userDefaults.set(data, forKey: "lessons")
        }
    }
    
    var groupOrTeacherName: String {
        get {
            return userDefaults.string(forKey: "groupOrTeacherName") ?? ""
        }
        
        set {
            userDefaults.setValue(newValue, forKey: "groupOrTeacherName")
        }
    }
    
    var cellNextColour: UIColor {
        get {
            let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: userDefaults.data(forKey: "cellNextColour") ?? Data())
            return color ?? #colorLiteral(red: 0, green: 0.568627451, blue: 0.9176470588, alpha: 1)
        }
        
        set {
            do {
                let colorData = try NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false) as NSData?
                userDefaults.set(colorData, forKey: "cellNextColour")
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    var cellCurrentColour: UIColor {
        get {
            let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: userDefaults.data(forKey: "cellCurrentColour") ?? Data())
            return color ?? UIColor.orange
        }
        
        set {
            do {
                let colorData = try NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false) as NSData?
                userDefaults.set(colorData, forKey: "cellCurrentColour")
            } catch let error {
                print(error.localizedDescription)
            }
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
    
}
