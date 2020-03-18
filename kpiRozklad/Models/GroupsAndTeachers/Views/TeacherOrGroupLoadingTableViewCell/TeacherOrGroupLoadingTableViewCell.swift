//
//  ServerGetTableViewCell.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 06.02.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

class TeacherOrGroupLoadingTableViewCell: UITableViewCell {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        activityIndicator.isHidden = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
