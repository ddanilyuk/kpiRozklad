//
//  NewLessonTalbleViewCellWithTextField.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 17.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

protocol TextFieldNewLessonTableViewCellDelegate {
    func userTappedShowDetails(on cell: TextFieldNewLessonTableViewCell, at indexPath: IndexPath)
}

class TextFieldNewLessonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainTextField: UITextField!
    
    @IBOutlet weak var detailsButton: UIButton!
        
    var delegate: TextFieldNewLessonTableViewCellDelegate?
    
    var isDetailsOpen: Bool = false
    
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(text: String? = "", placeholder: String?) {
        mainTextField.placeholder = placeholder
        mainTextField.text = text
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func didPressDetails(_ sender: UIButton) {
        guard let indexPath = indexPath else {
            assertionFailure("IndexPath not implemented")
            return
        }
        delegate?.userTappedShowDetails(on: self, at: indexPath)
        UIView.animate(withDuration: 0.3) {
            self.detailsButton.transform = CGAffineTransform(rotationAngle: self.isDetailsOpen ? 0 : .pi / -2)
        }
        isDetailsOpen.toggle()
    }
}
