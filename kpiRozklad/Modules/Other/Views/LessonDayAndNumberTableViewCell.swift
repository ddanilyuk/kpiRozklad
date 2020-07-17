//
//  LessonDayAndNumberTableViewCell.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 17.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

protocol LessonDayAndNumberTableViewCellDelegate {
    func pickerSelectDayAndNumber(picker: UIPickerView, lessonDay: DayName, lessonNumber: Int)
}


class LessonDayAndNumberTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var delegate: LessonDayAndNumberTableViewCellDelegate?
    
    var data: [DayName: [Int]] = [:] {
        didSet {
            print("data reloaded")
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            if data[.mounday]?.count ?? 0 != 0 {
                selectedNumber = data[selectedDay]?[0] ?? 0
            }
            delegate?.pickerSelectDayAndNumber(picker: pickerView, lessonDay: selectedDay, lessonNumber: selectedNumber)
        }
    }
    
    var selectedDay: DayName = .mounday
    
    var selectedNumber: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}


extension LessonDayAndNumberTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return data.count
        } else {
            return data[selectedDay]?.count ?? 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return DayName.allCases[row].rawValue
        } else {
            return "\(data[selectedDay]?[row] ?? 0) пара"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedDay = DayName.getDayNameFromNumber(row + 1) ?? .mounday
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            selectedNumber = data[selectedDay]?[0] ?? 0
        } else {
            selectedNumber = data[selectedDay]?[row] ?? 0
        }
        delegate?.pickerSelectDayAndNumber(picker: pickerView, lessonDay: selectedDay, lessonNumber: selectedNumber)
    }
}
