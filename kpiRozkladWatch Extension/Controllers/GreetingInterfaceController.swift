//
//  GreetingInterfaceController.swift
//  kpiRozkladWatch Extension
//
//  Created by Денис Данилюк on 24.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import WatchKit
import Foundation


class GreetingInterfaceController: WKInterfaceController {
    
    lazy var notificationCenter: NotificationCenter = {
        return NotificationCenter.default
    }()
    
    var notificationObserver: NSObjectProtocol?
    
    override func awake(withContext context: Any?) {
        
        notificationObserver = notificationCenter.addObserver(forName: NSNotification.Name("lessonsData"), object: nil, queue: nil, using: { (notification) in
            self.pop()
        })
    }
}
