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
            settings.sheduleType = .groups
            settings.teacherName = ""
            settings.teacherID = 0
            settings.sheduleType = .groups
            presentGroupOrTeacherChooser(requestType: .groups)
        } else {
            settings.sheduleType = .teachers
            settings.groupName = ""
            settings.groupID = 0
            settings.sheduleType = .teachers
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
        
        guard let groupsChooserNavigationController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: TeachersNavigationController.identifier) as? TeachersNavigationController else { return }
        
        deleteAllFromCoreData(managedContext: managedContext)

        
        if requestType == .groups {
            if settings.groupName == "" {
                groupsChooserNavigationController.groupAndTeacherControllerType = .isGroupChooser

                settings.sheduleType = .groups
                self.present(groupsChooserNavigationController, animated: true, completion: nil)
            }
        } else {
            if settings.teacherName == "" {
                groupsChooserNavigationController.groupAndTeacherControllerType = .isTeachersChooser

                settings.sheduleType = .teachers
                self.present(groupsChooserNavigationController, animated: true, completion: nil)
            }
        }
    }
}
