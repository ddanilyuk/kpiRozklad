//
//  ServerUpdateTableViewCell.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 27.01.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

class ServerUpdateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serverUpdateLabel: UILabel!
    @IBOutlet weak var deviceSaveLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        serverUpdateLabel.text = "00.00.1000"
        deviceSaveLabel.text = "00.00.1000"
    }
}
