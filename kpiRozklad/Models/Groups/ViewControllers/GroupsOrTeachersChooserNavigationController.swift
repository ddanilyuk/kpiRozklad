//
//  GroupsChooserNavigationController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 21.02.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

class GroupsOrTeachersChooserNavigationController: UINavigationController {
    
//    var isSheduleGroupChooser: Bool = false
//    
//    var isSheduleTeachersChooser: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()
        guard let teachersViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: TeachersViewController.identifier) as? TeachersViewController else { return }
        teachersViewController.isGroupViewController = true
        self.pushViewController(teachersViewController, animated: true)
    }
    
    
}
