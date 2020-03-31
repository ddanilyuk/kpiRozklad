//
//  SheduleDetailNavigationController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 04.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit
//import PanModal

class SheduleDetailNavigationController: UINavigationController, PanModalPresentable {

    var lesson: Lesson?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.topViewController
        panModalSetNeedsLayoutUpdate()
        
//        if #available(iOS 13.0, *) {
//            self.navigationController?.navigationBar.backgroundColor = tint
//        } else {
//            self.navigationController?.navigationBar.backgroundColor = .white
//        }
        navigationBar.backgroundColor = tint

    }

    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .default
//    }
    

    
    var panScrollable: UIScrollView? {
        return nil
    }

    
    var shortFormHeight: PanModalHeight {
        if screenHeight > 737 {
            return .contentHeight(((3.25 * screenHeight) / 8) + 20)
        } else {
            return .contentHeight(((3.25 * screenHeight) / 8) + 45)
        }
    }

    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(0)
    }

    var transitionDuration: Double {
        return 0.5
    }
}
