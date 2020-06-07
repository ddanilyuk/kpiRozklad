//
//  BoardViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 26.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


class BoardViewController: UIViewController, PanModalPresentable {
    
    var window: UIWindow?

    let settings = Settings.shared
    
    var isTouchedStudent: Bool = true
    
    @IBOutlet weak var teacherButton: UIButton!
    
    @IBOutlet weak var studentButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight = .contentHeight(340)

    var transitionDuration: Double {
        return 0.7
    }
    
    var cornerRadius: CGFloat {
        return 20.0
    }
    
    var allowsTapToDismiss: Bool {
        return false
    }
    
    var shortFormHeight: PanModalHeight  = .contentHeight(340)
    
    var allowsDragToDismiss: Bool {
        return false
    }
    
    var showDragIndicator: Bool {
        return false
    }
        
    var anchorModalToLongForm: Bool {
        return false
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.window = UIWindow(frame: UIScreen.main.bounds)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if #available(iOS 13.0, *) {
            studentButton.borderColor = .label
            teacherButton.borderColor = .tertiaryLabel
        } else {
            studentButton.borderColor = .black
            teacherButton.borderColor = .lightGray
        }
    }
    
    
    @IBAction func didPressTeacherButton(_ sender: UIButton) {
        isTouchedStudent = false
        
        if #available(iOS 13.0, *) {
            teacherButton.borderColor = .label
            studentButton.borderColor = .tertiaryLabel
        } else {
            teacherButton.borderColor = .black
            studentButton.borderColor = .gray
        }
    }
    
    
    @IBAction func didPressChoose(_ sender: UIButton) {
        if isTouchedStudent {
            global.sheduleType = .groups
            settings.teacherName = ""
            settings.teacherID = 0
            settings.isGroupsShedule = true
            settings.isTeacherShedule = false
            presentGroupOrTeacherChooser(requestType: .groups)
        } else {
            global.sheduleType = .teachers
            settings.groupName = ""
            settings.groupID = 0
            settings.isGroupsShedule = false
            settings.isTeacherShedule = true
            presentGroupOrTeacherChooser(requestType: .teachers)
        }
    }
    
    
    @IBAction func didPressStudentButton(_ sender: UIButton) {
        isTouchedStudent = true
        
        if #available(iOS 13.0, *) {
            studentButton.borderColor = .label
            teacherButton.borderColor = .tertiaryLabel
        } else {
            studentButton.borderColor = .black
            teacherButton.borderColor = .gray
        }
        
    }
            
        
    // MARK: - presentGroupChooser
    /// Func which present `GroupChooserViewController` (navigationGroupChooser)
    func presentGroupOrTeacherChooser(requestType: SheduleType) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if requestType == .groups {
            if settings.groupName == "" {
                deleteAllFromCoreData(managedContext: managedContext)
                guard let groupsChooserNavigationController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: TeachersNavigationController.identifier) as? TeachersNavigationController else { return }
                
                groupsChooserNavigationController.isSheduleGroupChooser = true
                
                self.present(groupsChooserNavigationController, animated: true, completion: nil)
            }
        } else {
            if settings.teacherName == "" {
                deleteAllFromCoreData(managedContext: managedContext)
                guard let groupsChooserNavigationController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: TeachersNavigationController.identifier) as? TeachersNavigationController else { return }
                
                groupsChooserNavigationController.isSheduleTeachersChooser = true
                global.sheduleType = .teachers
                
                self.present(groupsChooserNavigationController, animated: true, completion: nil)
            }
        }
    }
}
