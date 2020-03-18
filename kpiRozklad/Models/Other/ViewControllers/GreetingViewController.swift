//
//  GreetingViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 24.02.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

class GreetingViewController: UIViewController {
    
    var window: UIWindow?
    
    var settings = Settings.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        self.window = UIWindow(frame: UIScreen.main.bounds)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func didPressTeacherButton(_ sender: UIButton) {
        global.sheduleType = .teachers
        settings.groupName = ""
        settings.groupID = 0
        settings.isGroupsShedule = false
        settings.isTeacherShedule = true
//        showMainStoryboard()
        presentGroupOrTeacherChooser(requestType: .teachers)
    }
    
    @IBAction func didPressStudentButton(_ sender: UIButton) {
        global.sheduleType = .groups
        settings.teacherName = ""
        settings.teacherID = 0
        settings.isGroupsShedule = true
        settings.isTeacherShedule = false
//        showMainStoryboard()
        presentGroupOrTeacherChooser(requestType: .groups)

    }
    
    private func showMainStoryboard() {
        guard let window = window else { return }

        let viewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
        
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        viewController?.modalTransitionStyle = .crossDissolve

        // The duration of the transition animation, measured in seconds.
        let duration: TimeInterval = 0.4

        // Creates a transition animation.
        // Though `animations` is optional, the documentation tells us that it must not be nil. ¯\_(ツ)_/¯
        UIView.transition(with: window, duration: duration, options: options, animations: {}, completion:
            { completed in
            // maybe do something on completion here
        })
    }
    
    
    
    // MARK: - presentGroupChooser
    /// Func which present `GroupChooserViewController` (navigationGroupChooser)
    func presentGroupOrTeacherChooser(requestType: SheduleType) {
        if requestType == .groups {
            if settings.groupName == "" {
                deleteAllFromCoreData()
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                guard let groupsChooserNavigationController = mainStoryboard.instantiateViewController(withIdentifier: TeachersNavigationController.identifier) as? TeachersNavigationController else { return }
                
                groupsChooserNavigationController.isSheduleGroupChooser = true
                
                self.present(groupsChooserNavigationController, animated: true, completion: nil)
            }
        } else {
            if settings.teacherName == "" {
                deleteAllFromCoreData()
                
                let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                guard let groupsChooserNavigationController = mainStoryboard.instantiateViewController(withIdentifier: TeachersNavigationController.identifier) as? TeachersNavigationController else { return }
                
                groupsChooserNavigationController.isSheduleTeachersChooser = true
                global.sheduleType = .teachers
                

                
                self.present(groupsChooserNavigationController, animated: true, completion: nil)
            }
        }
        
    }
    
    
}
