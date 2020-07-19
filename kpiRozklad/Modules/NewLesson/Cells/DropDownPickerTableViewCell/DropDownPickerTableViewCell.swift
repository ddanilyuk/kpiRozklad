//
//  DropDownPickerTableViewCell.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 17.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


/// Delegate
protocol DropDownPickerTableViewCellDelegate {
    func userChangedDropDownCellAt(fatherIndexPath: IndexPath, text: String, inPickerRow: Int)
}


class DropDownPickerTableViewCell: UITableViewCell {

    @IBOutlet weak var pickerView: UIPickerView!
    
    var delegate: DropDownPickerTableViewCellDelegate?
    
    /// Index of cell which drop down this cell
    var fatherIndexPath: IndexPath?
    
    /// Previous selected index
    var previousSelectedIndex: Int = 0 {
        didSet {
            if previousSelectedIndex == 0 {
                guard let fatherIndexPath = fatherIndexPath else {
                    assertionFailure("IndexPath not implemented")
                    return
                }
                delegate?.userChangedDropDownCellAt(fatherIndexPath: fatherIndexPath, text: dataArray[0], inPickerRow: 0)
            }
            
            selectedRow = previousSelectedIndex
            pickerView.selectRow(previousSelectedIndex, inComponent: 0, animated: false)
            pickerView.reloadAllComponents()
        }
    }
    
    /// Array with data for picker
    var dataArray: [String] = []
    
    /// Used for choosing which row need to be blue
    var selectedRow: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pickerView.delegate = self
        pickerView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        selectedRow = 0
    }
}


extension DropDownPickerTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        
        let isRowSelected = selectedRow == row

        var textColor = isRowSelected ? UIColor.blue : UIColor.black

        if #available(iOS 13.0, *) {
            textColor = isRowSelected ? UIColor.link : UIColor.label
        }
        
        let attributtedString = NSAttributedString(string: dataArray[row], attributes: [
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .regular)
        ])
        
        pickerLabel.textAlignment = .center
        pickerLabel.attributedText = attributtedString
        return pickerLabel
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let fatherIndexPath = fatherIndexPath else {
            assertionFailure("IndexPath not implemented")
            return
        }
        selectedRow = row
        delegate?.userChangedDropDownCellAt(fatherIndexPath: fatherIndexPath, text: dataArray[row], inPickerRow: row)
        pickerView.reloadAllComponents()
    }
}
