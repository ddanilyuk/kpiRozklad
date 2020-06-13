//
//  LessonType.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 13.06.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


enum LessonType: String, Codable {
    case empty = ""
    case лаб = "Лаб"
    case лек1 = "Лек"
    case лек2 = "лек"
    case прак = "Прак"
}
