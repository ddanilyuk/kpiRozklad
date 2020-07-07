//
//  DayName.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 13.06.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


public enum DayName: String, Codable, Comparable, CaseIterable, Hashable {
    
    case mounday = "Понеділок"
    case tuesday = "Вівторок"
    case wednesday = "Середа"
    case thursday = "Четвер"
    case friday = "П’ятниця"
    case saturday = "Субота"
    
    
    private var sortOrder: Int {
        switch self {
        case .mounday:
            return 1
        case .tuesday:
            return 2
        case .wednesday:
            return 3
        case .thursday:
            return 4
        case .friday:
            return 5
        case .saturday:
            return 6
        }
    }
    
    static func getDayNameFromNumber(_ number: Int) -> DayName? {
        switch number {
        case 1:
            return .mounday
        case 2:
            return .tuesday
        case 3:
            return .wednesday
        case 4:
            return .thursday
        case 5:
            return .friday
        case 6:
            return .saturday
        default:
            return nil
        }
    }

    public static func ==(lhs: DayName, rhs: DayName) -> Bool {
        return lhs.sortOrder == rhs.sortOrder
    }

    public static func <(lhs: DayName, rhs: DayName) -> Bool {
       return lhs.sortOrder < rhs.sortOrder
    }
    
}
