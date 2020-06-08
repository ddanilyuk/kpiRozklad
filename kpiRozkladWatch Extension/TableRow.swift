//
//  TableRow.swift
//  kpiRozkladWatch Extension
//
//  Created by Денис Данилюк on 08.06.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import WatchKit

class TableRow: NSObject {
    @IBOutlet weak var rowGroup: WKInterfaceGroup!
    
    @IBOutlet weak var lessonNameLabel: WKInterfaceLabel!
    
    @IBOutlet weak var lessonRoomLabel: WKInterfaceLabel!
    
    var lesson: Lesson? {
        didSet {
            self.lessonNameLabel.setText("\(lesson?.lessonName ?? "No name")")
            self.lessonRoomLabel.setText("\(lesson?.lessonRoom ?? "") \(lesson?.lessonType.rawValue ?? "")")
        }
    }
}
