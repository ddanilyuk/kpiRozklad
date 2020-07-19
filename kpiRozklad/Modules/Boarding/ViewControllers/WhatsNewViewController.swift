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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = tint
        contentView.backgroundColor = tint
        // Do any additional setup after loading the view.
    }
    @IBAction func didPressDone(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
