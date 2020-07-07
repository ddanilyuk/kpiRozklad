//
//  DetailedInterfaceController.swift
//  kpiRozkladWatch Extension
//
//  Created by Денис Данилюк on 12.06.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit
import WatchKit

class DetailedInterfaceController: WKInterfaceController {
    
    @IBOutlet var lessonNameLabel: WKInterfaceLabel!
    @IBOutlet var roomNameLabel: WKInterfaceLabel!
    @IBOutlet var teacherNameLabel: WKInterfaceLabel!
    @IBOutlet var dayNameLabel: WKInterfaceLabel!
    @IBOutlet var groupsNameLabel: WKInterfaceLabel!
    
    
    override func awake(withContext context: Any?) {
        guard let lesson = context as? Lesson else { return }
        lessonNameLabel.setText(lesson.lessonName)
        roomNameLabel.setText("\(lesson.lessonRoom) \(lesson.lessonType.rawValue)")
        
        dayNameLabel.setText(lesson.dayName.rawValue + ", " + lesson.lessonWeek.rawValue + " тиждень")
        groupsNameLabel.setText(getGroupsOfLessonString(lesson: lesson))
        
        if let teacher = lesson.teacher {
            if teacher.teacherFullName != "" {
                teacherNameLabel.setText(teacher.teacherFullName)
            } else if teacher.teacherName != "" {
                teacherNameLabel.setText(teacher.teacherName)
            } else {
                teacherNameLabel.setText(lesson.teacherName)
            }
        }
    }
    
}
