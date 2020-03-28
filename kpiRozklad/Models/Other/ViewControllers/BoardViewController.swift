//
//  BoardViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 26.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit
//import PanModal

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

//    var shortFormHeight: PanModalHeight {
//        return .contentHeight(360)
//    }

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
    
    
//    var allowsExtendedPanScrolling: Bool {
//        return false
//    }
    
    
//    var isUserInteractionEnabled: Bool {
//        return true
//    }
    
//    var bottomLayoutOffset: CGFloat {
//        return 200
//    }

//    var topOffset: CGFloat {
//        return 200
//    }
    
    var allowsDragToDismiss: Bool {
        return false
    }
    
    var showDragIndicator: Bool {
        return false
    }
    
//    var anchorModalToLongForm: Bool
    
    var anchorModalToLongForm: Bool {
        return false
    }
    
//    func panModalWillDismiss() {
//
//        panModalTransition(to: .longForm)
//    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.window = UIWindow(frame: UIScreen.main.bounds)
//        teacherButton.state. = UIButton.State.normal
        
        
        
    
//        longFormHeight = .contentHeight(360)
        
        // Do any additional setup after loading the view.
    }
    
    
    
//    @IBAction func didPressStudent(_ sender: UIButton) {
////        self.longFormHeight = .maxHeightWithTopInset(20)
////        self.shortFormHeight = .maxHeightWithTopInset(20)
//        DispatchQueue.main.async {
//            self.panModalSetNeedsLayoutUpdate()
//            //        longFormHeight = .contentHeight(600)
////            self.longFormHeight = .contentHeight(600)
////            self.shortFormHeight = .contentHeight(600)
////            self.longFormHeight = .contentHeight(600)
////            self.shortFormHeight = .contentHeight(600)
////            self.panModalTransition(to: .longForm)
////            panModalTransition(to: .shortForm)
//            guard let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SheduleViewController") as? SheduleViewController else {
//                return
//            }
//            
//            self.present(vc, animated: true, completion: nil)
////            self.view = vc.view
////            presentPanModal(vc)
//        }
//        
//    }
    
    override func viewDidAppear(_ animated: Bool) {
//        self.longFormHeight = .contentHeight(600)
//        self.shortFormHeight = .contentHeight(600)
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

        
            
    //        showMainStoryboard()
//            presentGroupOrTeacherChooser(requestType: .teachers)
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
            
//            global.sheduleType = .groups
//            settings.teacherName = ""
//            settings.teacherID = 0
//            settings.isGroupsShedule = true
//            settings.isTeacherShedule = false
    //        showMainStoryboard()
//            presentGroupOrTeacherChooser(requestType: .groups)
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
                    
                    if #available(iOS 13, *) {
                        self.present(groupsChooserNavigationController, animated: true, completion: nil)

                    } else {
    //                    self.navigationController?.pushViewController(groupsChooserNavigationController, animated: true)
                        self.present(groupsChooserNavigationController, animated: true, completion: nil)

                    }
                }
            } else {
                if settings.teacherName == "" {
                    deleteAllFromCoreData()
                    
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    guard let groupsChooserNavigationController = mainStoryboard.instantiateViewController(withIdentifier: TeachersNavigationController.identifier) as? TeachersNavigationController else { return }
                    
                    groupsChooserNavigationController.isSheduleTeachersChooser = true
                    global.sheduleType = .teachers
                    
                    if #available(iOS 13, *) {
                        self.present(groupsChooserNavigationController, animated: true, completion: nil)

                    } else {
    //                    self.navigationController?.pushViewController(groupsChooserNavigationController, animated: true)
                        self.present(groupsChooserNavigationController, animated: true, completion: nil)

                    }
                    
                }
            }
            
        }


}

