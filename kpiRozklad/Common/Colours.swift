//
//  Colours.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 03.12.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

public var tint: UIColor = {
    if #available(iOS 13, *) {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                /// Return the color for Dark Mode
                return UIColor.black
                
            } else {
                /// Return the color for Light Mode
                return UIColor.tertiarySystemGroupedBackground
            }
        }
    } else {
        /// Return a fallback color for iOS 12 and lower.
        return UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
    }
}()

public var blue: UIColor = {
    return UIColor(red: 67/255, green: 127/255, blue: 188/255, alpha: 1)
}()

