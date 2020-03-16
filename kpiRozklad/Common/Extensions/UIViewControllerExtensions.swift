//
//  UIViewControllerExtensions.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 14.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


extension UIViewController {
    
    class var identifier: String {
        return String(describing: self)
    }
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
