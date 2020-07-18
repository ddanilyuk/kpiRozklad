//
//  LessonDayAndNumberTableViewCell.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 17.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


protocol LessonDayAndNumberTableViewCellDelegate {
    func userSelectDayAndNumber(lessonDay: DayName, lessonNumber: Int)
}


class LessonDayAndNumberTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var delegate: LessonDayAndNumberTableViewCellDelegate?
    
    var data: [DayName: [Int]] = [:] {
        didSet {
            selectedDay = .mounday
            if data[selectedDay]?.count ?? 0 != 0 {
                /// If mounday is full, lessonNumber == 0
                selectedNumber = data[selectedDay]?[0] ?? 0
            }
            pickerView.selectRow(0, inComponent: 0, animated: true)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            pickerView.reloadAllComponents()

            delegate?.userSelectDayAndNumber(lessonDay: selectedDay, lessonNumber: selectedNumber)
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
    
    func configureCell(day: DayName, lessonNumber: Int) {
        self.selectedDay = day
        self.selectedNumber = lessonNumber
        let possibleLessonNumbers = data[selectedDay] ?? []
        let index = Int(possibleLessonNumbers.sorted().firstIndex(of: selectedNumber) ?? 0)
        pickerView.selectRow(day.sortOrder - 1, inComponent: 0, animated: true)
        pickerView.selectRow(index, inComponent: 1, animated: true)
        pickerView.reloadAllComponents()

        delegate?.userSelectDayAndNumber(lessonDay: selectedDay, lessonNumber: selectedNumber)
    }
}


extension LessonDayAndNumberTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? data.count : data[selectedDay]?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? DayName.allCases[row].rawValue : "\(data[selectedDay]?[row] ?? 0) пара"
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
        delegate?.userSelectDayAndNumber(lessonDay: selectedDay, lessonNumber: selectedNumber)
    }
}
