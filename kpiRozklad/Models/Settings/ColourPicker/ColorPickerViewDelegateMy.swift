//
//  ColorPickerViewDelegateMy.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 14.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

@objc public protocol ColorPickerViewDelegate: class {
    
    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath)
    
    @objc optional func colorPickerView(_ colorPickerView: ColorPickerView, didDeselectItemAt indexPath: IndexPath)
    
}
