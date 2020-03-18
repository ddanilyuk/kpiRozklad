//
//  GroupsChooserNavigationController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 21.02.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

class GroupsNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let teachersViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: GroupsAndTeachersViewController.identifier) as? GroupsAndTeachersViewController else { return }
        teachersViewController.isGroupViewController = true
        self.pushViewController(teachersViewController, animated: true)
    }
}
