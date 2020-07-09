//
//  UIActivityIndicator+Extensions.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 09.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


extension UIActivityIndicatorView {
    
    func stopAndHide() {
        DispatchQueue.main.async {
            self.stopAnimating()
            self.isHidden = true
        }
    }
    
    func startAndShow() {
        DispatchQueue.main.async {
            self.startAnimating()
            self.isHidden = false
        }
    }
    
}
