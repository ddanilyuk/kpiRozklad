//
//  StoreUserDefaults.swift
//  kpiRozkladWatch Extension
//
//  Created by Денис Данилюк on 10.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


public class StoreUserDefaults {
//    private var userDefaults = UserDefaults.standard
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
    
}
     
