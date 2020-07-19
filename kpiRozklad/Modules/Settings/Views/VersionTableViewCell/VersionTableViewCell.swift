//
//  VersionTableViewCell.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 19.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


protocol VersionTableViewCellDelegate {
    func userPressVersionButton()
}


class VersionTableViewCell: UITableViewCell {
    
    var delegate: VersionTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func didPressVersionButton(_ sender: UIButton) {
        delegate?.userPressVersionButton()
    }
}
