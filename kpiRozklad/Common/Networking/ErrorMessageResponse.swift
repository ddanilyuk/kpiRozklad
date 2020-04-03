//
//  ErrorMessageResponse.swift
//  testPresent
//
//  Created by Денис Данилюк on 22.03.2020.
//  Copyright © 2020 Денис Данилюк. All rights reserved.
//

import Foundation

struct ErrorMessageResponse: Decodable {
    let statusCode: Int
    let timeStamp: UInt64
    let message: String
}

struct ArrayDataResponse<T: Decodable>: Decodable {
    var data: [T]
}
