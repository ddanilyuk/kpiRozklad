//
//  MyNavigationController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 28.02.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

class TeachersNavigationController: UINavigationController {
    
    var isSheduleGroupChooser: Bool = false
    
    var isSheduleTeachersChooser: Bool = false
    
    var isTeacherViewController: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isSheduleTeachersChooser == false && global.sheduleType == .teachers {
            isTeacherViewController = true
        }
    }
}
