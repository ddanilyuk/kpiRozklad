//
//  WhatsNewViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 19.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

class WhatsNewViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    
    let settings = Settings.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = tint
        contentView.backgroundColor = tint
        
        self.navigationController?.navigationItem.backBarButtonItem = nil
        setLargeTitleDisplayMode(.never)
    }
    
    @IBAction func didPressDone(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        settings.isShowWhatsNewInVersion2Point0 = true
    }

}
