//
//  SheduleDetailNavigationController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 04.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit
import PanModal

class SheduleDetailNavigationController: UINavigationController, PanModalPresentable {

    var lesson: Lesson?
//
//    var hasLoaded: Bool = false
//
//    var isShortFormEnabled = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panModalSetNeedsLayoutUpdate()

//        panModalSetNeedsLayoutUpdate()
//        panModalTransition(to: .shortForm)
            
    }
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .default
//    }

//    var panScrollable: UIScrollView? {
//        return nil
//    }

//    var shortFormHeight: PanModalHeight {
//        return .contentHeight((3 * screenHeight)/8)
//    }
//
//    var shortFormHeight: PanModalHeight {
//        if hasLoaded {
//            return .contentHeight((3 * screenHeight)/8)
//        }
//        return .maxHeight
//    }

//    var shortFormHeight: PanModalHeight {
//        return isShortFormEnabled ? .contentHeight((3 * screenHeight)/8) : .maxHeightWithTopInset(0)
//    }
    
//    var longFormHeight: PanModalHeight {
//        return .maxHeightWithTopInset(0)
//    }

//    var transitionDuration: Double {
//        return 0.7
//    }
    
//    var anchorModalToLongForm: Bool {
//        return false
//    }
//    
//    func willTransition(to state: PanModalPresentationController.PresentationState) {
//        guard isShortFormEnabled, case .longForm = state
//            else { return }
//
//        isShortFormEnabled = false
//        panModalSetNeedsLayoutUpdate()
//    }
//    private let navGroups = SheduleDetailViewController()

//    init() {
//        super.init(nibName: nil, bundle: Bundle.main)
//        guard let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: SheduleDetailViewController.identifier) as? SheduleDetailViewController else {
//            return
//        }
//        viewControllers = [vc]
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
    

//    var panModalBackgroundColor: UIColor {
//        return UIColor.black.withAlphaComponent(0.4)
//    }
    
    
    
    
    
    
//    override func popViewController(animated: Bool) -> UIViewController? {
//        let vc = super.popViewController(animated: animated)
//        panModalSetNeedsLayoutUpdate()
//        return vc
//    }
//
//    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
//        super.pushViewController(viewController, animated: animated)
//        panModalSetNeedsLayoutUpdate()
//    }
//
//    // MARK: - Pan Modal Presentable
//
//    var panScrollable: UIScrollView? {
////        return (topViewController as? PanModalPresentable)?.panScrollable
//        return nil
//    }
//
//    var longFormHeight: PanModalHeight {
//        return .maxHeight
//    }
//
//    var shortFormHeight: PanModalHeight {
//        return .contentHeight((3 * screenHeight)/8)
//    }

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    var panScrollable: UIScrollView? {
        return nil
    }

    var shortFormHeight: PanModalHeight {
        return .contentHeight((3 * screenHeight)/8)
    }

    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(0)
    }

    var transitionDuration: Double {
        return 0.5
    }
    
//    var panScrollable: UIScrollView? {
//        return (topViewController as? PanModalPresentable)?.panScrollable
//    }

}
