//
//  NewLessonTalbleViewCellWithTextField.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 17.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


protocol TextFieldAndButtonTableViewCellDelegate {
    func userDidPressShowDetails(at indexPath: IndexPath)
    func userChangeTextInTextField(at indexPath: IndexPath, text: String)
}


class TextFieldAndButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainTextField: UITextField!
    
    @IBOutlet weak var detailsButton: UIButton!
    
    var delegate: TextFieldAndButtonTableViewCellDelegate?

    var isDetailsOpen: Bool = false
    
    /// Index path of cell. Must be changed when table vie create new cell.
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainTextField.addTarget(self, action: #selector(textFieldDidChange), for:.editingChanged)
    }
    
    /// Configure text field with text or placeholder
    func configureCell(text: String? = nil, placeholder: String? = nil) {
        mainTextField.placeholder = placeholder
        mainTextField.text = text
    }
    
    @objc func textFieldDidChange() {
        guard let indexPath = indexPath else {
            assertionFailure("IndexPath not implemented")
            return
        }
        delegate?.userChangeTextInTextField(at: indexPath, text: String(mainTextField.text ?? ""))
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func didPressDetails(_ sender: UIButton) {
        guard let indexPath = indexPath else {
            assertionFailure("IndexPath not implemented")
            return
        }
        delegate?.userDidPressShowDetails(at: indexPath)
        UIView.animate(withDuration: 0.3) {
            self.detailsButton.transform = CGAffineTransform(rotationAngle: self.isDetailsOpen ? 0 : .pi / -2)
        }
        isDetailsOpen.toggle()
    }
}
