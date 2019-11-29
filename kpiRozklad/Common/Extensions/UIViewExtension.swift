//
//  UIViewExtension.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 26.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

extension UIView {
    
    class var identifier: String {
        return String(describing: self)
    }
}

extension UIViewController {
    
    class var identifier: String {
        return String(describing: self)
    }
}
