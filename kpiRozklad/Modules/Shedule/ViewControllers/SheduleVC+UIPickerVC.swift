//
//  SheduleVC+UIPickerVC.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 30.11.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit


extension SheduleViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 6
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let array = ["1 пара", "2 пара", "3 пара", "4 пара", "5 пара", "6 пара"]

        var colour = UIColor.white
        
        switch traitCollection.userInterfaceStyle {
        case .light:
            colour = .black
        case .dark:
            colour = .white
        case .unspecified:
            colour = .white
        @unknown default:
            colour = .white
        }
        return NSAttributedString(string: array[row], attributes: [NSAttributedString.Key.foregroundColor : colour])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lessonNumberFromPicker = row + 1
    }
    
}
