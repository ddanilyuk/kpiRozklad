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
        return UIColor.tertiarySystemGroupedBackground
    }
}()

