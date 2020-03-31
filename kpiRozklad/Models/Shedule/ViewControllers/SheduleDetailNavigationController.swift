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
        print(self.parent?.description)
//        self.topViewController
        panModalSetNeedsLayoutUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector:#selector(reloadAfterOpenApp), name: UIApplication.willEnterForegroundNotification, object: nil)

    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .default
//    }
    
    @objc func reloadAfterOpenApp() {
        guard let top = self.parent else {
            return
        }
//        top.navigationController?.navigationBar.backgroundColor = .green
        top.setLargeTitleDisplayMode(.never)
    }
    
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
