//
//  Meta.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 13.06.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


struct Meta: Codable {
    let totalCount: String?
    let offset, limit: Int?

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case offset, limit
    }
}
