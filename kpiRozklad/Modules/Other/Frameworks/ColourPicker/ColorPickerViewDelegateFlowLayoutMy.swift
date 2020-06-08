//
//  ColorPickerViewDelegateFlowLayoutMy.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 14.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

@objc public protocol ColorPickerViewDelegateFlowLayout: class {
    
    @objc optional func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize
    
    @objc optional func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    
    @objc optional func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    
    @objc optional func colorPickerView(_ colorPickerView: ColorPickerView, insetForSectionAt section: Int) -> UIEdgeInsets
}
