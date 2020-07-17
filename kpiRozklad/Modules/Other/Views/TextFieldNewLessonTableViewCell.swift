//
//  NewLessonTalbleViewCellWithTextField.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 17.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

protocol TextFieldNewLessonTableViewCellDelegate {
    func userTappedShowDetails(on cell: TextFieldNewLessonTableViewCell)
}

class TextFieldNewLessonTableViewCell: UITableViewCell, TextFieldNewLessonTableViewCellDelegate {
    
    @IBOutlet weak var mainTextField: UITextField!
    
    @IBOutlet weak var detailsButton: UIButton!
    
    var isDetailsOpen: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(text: String? = "", placeholder: String?) {
        mainTextField.placeholder = placeholder
        mainTextField.text = text
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didPressDetails(_ sender: UIButton) {
        print("complition called")
        userTapOnButton {  }
        UIView.animate(withDuration: 0.5) {
            self.detailsButton.transform = CGAffineTransform(rotationAngle: self.isDetailsOpen ? 0 : .pi / -2)
        }
        isDetailsOpen.toggle()
    }
    
    
    
    func userTappedShowDetails(on cell: TextFieldNewLessonTableViewCell) {
        print("tapped")
    }
    
//    func userTapOnButton(with complition: @escaping () -> ()) {
//        print("before complition")
//        complition()
//    }
    
}
