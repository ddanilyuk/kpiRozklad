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
    
    @IBOutlet weak var timeStartLabel: WKInterfaceLabel!
    
    @IBOutlet weak var timeEndLabel: WKInterfaceLabel!
    
    var lesson: Lesson? {
        didSet {
            self.lessonNameLabel.setText("\(lesson?.lessonName ?? "No name")")
            self.lessonRoomLabel.setText("\(lesson?.lessonRoom ?? "") \(lesson?.lessonType.rawValue ?? "")")
            self.timeStartLabel.setText(String(lesson?.timeStart[..<5] ?? "00:00"))
            self.timeEndLabel.setText(String(lesson?.timeEnd[..<5] ?? "00:00"))
        }
    }
}
