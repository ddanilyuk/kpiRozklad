//
//  CellWithOneSectionPickerTableViewCell.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 17.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

class CellWithOneSectionPickerTableViewCell: UITableViewCell {

    @IBOutlet weak var pickerView: UIPickerView!
    
    let testArray = ["Інженерія програмного забезпечення-3. Проектування програмного забезпечення",
                     "Методи оптимізації та планування експерименту",
                     "Комп'ютерна електроніка",
                     "Архітектура комп'ютерів-1. Арифметичні та управляючі пристрої",
                     "Іноземна мова загальнотехнічного спрямування",
                     "Фізичне виховання"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pickerView.delegate = self
        pickerView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension CellWithOneSectionPickerTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return testArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        return testArray[component]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
