//
//  CellWithOneSectionPickerTableViewCell.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 17.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

protocol CellWithOneSectionPickerTableViewCellDelegate {
    func pickerCellUpdate(with Picker: UIPickerView, atFatherIndexPath indexPath: IndexPath, text: String)
}

class CellWithOneSectionPickerTableViewCell: UITableViewCell {

    @IBOutlet weak var pickerView: UIPickerView!
    
    var delegate: CellWithOneSectionPickerTableViewCellDelegate?
    
    var fatherIndexPath: IndexPath?
    
//    let testArray = ["Інженерія програмного забезпечення-3. Проектування програмного забезпечення",
//                     "Методи оптимізації та планування експерименту",
//                     "Комп'ютерна електроніка",
//                     "Архітектура комп'ютерів-1. Арифметичні та управляючі пристрої",
//                     "Іноземна мова загальнотехнічного спрямування",
//                     "Фізичне виховання"]
    
    var dataArray: [String] = [] {
        didSet {
            pickerView.selectRow(0, inComponent: 0, animated: false)
            pickerView.reloadAllComponents()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        prepareForReuse()
        pickerView.delegate = self
        pickerView.dataSource = self
//        pickerView.reloadAllComponents()

//        pickerView.setValue(UIColor.red, forKey: "backgroundColor")

//        pickerView.tintColor = .blue
//        pickerView.backgroundColor = .blue
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        pickerView = nil
//        pickerView.reloadAllComponents()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension CellWithOneSectionPickerTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var color = UIColor.clear
        // Todo
        if #available(iOS 13.0, *) {
            color = (row == pickerView.selectedRow(inComponent: component)) ? UIColor.link : UIColor.link
        } else {
            color = (row == pickerView.selectedRow(inComponent: component)) ? UIColor.blue : UIColor.blue
        }
        return NSAttributedString(string: dataArray[row], attributes: [NSAttributedString.Key.foregroundColor: color])
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        let pickerLabel = UILabel()
//
//        var textColor = UIColor.clear
//        var backgroundColor = UIColor.clear
//
//        if #available(iOS 13.0, *) {
//            textColor = (row == pickerView.selectedRow(inComponent: component)) ? UIColor.white : UIColor.link
//            backgroundColor = (row == pickerView.selectedRow(inComponent: component)) ? UIColor.link : UIColor.white
//        } else {
//            textColor = (row == pickerView.selectedRow(inComponent: component)) ? UIColor.white : UIColor.blue
//            backgroundColor = (row == pickerView.selectedRow(inComponent: component)) ? UIColor.blue : UIColor.white
//        }
//        let attributtedString = NSAttributedString(string: dataArray[row], attributes: [
//            NSAttributedString.Key.foregroundColor: textColor,
//            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold)
//        ])
//
//        pickerLabel.backgroundColor = backgroundColor
//        pickerLabel.textAlignment = .center
//        pickerLabel.attributedText = attributtedString
//        return pickerLabel
//    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let fatherIndexPath = fatherIndexPath else {
            assertionFailure("IndexPath not implemented")
            return
        }
        delegate?.pickerCellUpdate(with: pickerView, atFatherIndexPath: fatherIndexPath, text: dataArray[row])
        pickerView.reloadAllComponents()
    }
}
