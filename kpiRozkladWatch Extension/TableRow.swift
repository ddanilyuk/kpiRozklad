//
//  TableRow.swift
//  kpiRozkladWatch Extension
//
//  Created by Денис Данилюк on 07.06.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit
import AVFoundation
import WatchKit


class TableRow: NSObject {

    @IBOutlet weak var lessonNameLabel: WKInterfaceLabel!
    @IBOutlet weak var roomNameLabel: WKInterfaceLabel!
    
    var lesson: Lesson? {
        didSet {
            self.lessonNameLabel.setText("\(lesson?.lessonName ?? "No name")")
            self.lessonNameLabel.setText("\(lesson?.lessonRoom ?? "") \(lesson?.lessonType.rawValue ?? "")")

        }
    }
}
