//
//  WeekType.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 05.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

public enum WeekType: String, Codable, CaseIterable, Hashable, Comparable {
    public static func < (lhs: WeekType, rhs: WeekType) -> Bool {
        if lhs != rhs {
            return Int(lhs.rawValue) ?? 0 < Int(rhs.rawValue) ?? 0
        } else {
            return false
        }
    }
    
    case first = "1"
    case second = "2"
    
    mutating func toogle() {
        self = self == .first ? .second : .first
    }
}
