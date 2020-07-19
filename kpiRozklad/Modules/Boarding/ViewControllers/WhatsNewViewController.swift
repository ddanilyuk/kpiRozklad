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
        if #available(iOS 13.0, *) {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        settings.isShowWhatsNewInVersion2Point0 = true
    }

}
