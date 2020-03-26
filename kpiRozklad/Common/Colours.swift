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

//public var blue: UIColor = {
//    return UIColor(red: 67/255, green: 127/255, blue: 188/255, alpha: 1)
//}()

public var sectionColour: UIColor = {
    if #available(iOS 13, *) {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                /// Return the color for Dark Mode
                return #colorLiteral(red: 0.1215686275, green: 0.1294117647, blue: 0.1411764706, alpha: 1)
                
            } else {
                /// Return the color for Light Mode
//                return UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                return UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
            }
        }
    } else {
        /// Return a fallback color for iOS 12 and lower.
        return UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
    }
}()

public var tableViewBackground: UIColor = {
    if #available(iOS 13, *) {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                /// Return the color for Dark Mode
                return .black
                
            } else {
                /// Return the color for Light Mode
//                return UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
                return UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
            }
        }
    } else {
        /// Return a fallback color for iOS 12 and lower.
        return UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
    }
}()


public var seettingsTableViewBackgroundColour: UIColor = {
    if #available(iOS 13, *) {
        return .secondarySystemGroupedBackground
    } else {
        /// Return a fallback color for iOS 12 and lower.
        return  UIColor.white
    }
}()


