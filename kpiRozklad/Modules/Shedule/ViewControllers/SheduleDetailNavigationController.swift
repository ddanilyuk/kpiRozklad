//
//  SheduleDetailNavigationController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 04.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


class SheduleDetailNavigationController: UINavigationController, PanModalPresentable {

    var lesson: Lesson?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        panModalSetNeedsLayoutUpdate()
        navigationBar.backgroundColor = tint
    }
}
