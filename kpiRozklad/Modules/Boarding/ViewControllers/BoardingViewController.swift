//
//  FirstViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 26.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


class BoardingViewController: UIViewController {

    var statusBarStyle = UIStatusBarStyle.lightContent { didSet { setNeedsStatusBarAppearanceUpdate() } }
    override var preferredStatusBarStyle: UIStatusBarStyle { statusBarStyle }
    var isPopUpPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentPopUp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presentPopUp()
    }
    
    func presentPopUp() {
        if !isPopUpPresented {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
                guard let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: PopUpPanModalViewController.identifier) as? PopUpPanModalViewController else { return }
                self.isPopUpPresented = true
                
                self.presentPanModal(vc)
            }
        }
    }
    
}
