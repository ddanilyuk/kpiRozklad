//
//  UITableViewCellExtensions.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 14.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


extension UITableViewCell {
    func separator(shouldBeHidden: Bool) {
        separatorInset.left += shouldBeHidden ? bounds.size.width : 0
    }
}
