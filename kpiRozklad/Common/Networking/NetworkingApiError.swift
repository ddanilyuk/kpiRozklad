//
//  NetworkingApiError.swift
//  testPresent
//
//  Created by Денис Данилюк on 22.03.2020.
//  Copyright © 2020 Денис Данилюк. All rights reserved.
//

import Foundation


enum NetworkingApiError: LocalizedError {
    // Data
    case noDataReturned

    // Group not found
    case groupNotFound
    
    // Lessons not found
    case lessonsNotFound
    
    var errorDescription: String? {
        switch self {
        case .noDataReturned:
            return "No data returned as a response for the request"
        case .groupNotFound:
            return "Group not found"
        case .lessonsNotFound:
            return "Lessons not found"
        }
    }
    
}
