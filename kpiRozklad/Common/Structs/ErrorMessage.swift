//
//  Error.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 11.12.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import Foundation


// MARK: - Error
struct ErrorMessage: Codable {
    let statusCode, timeStamp: Int
    let message: String
}
