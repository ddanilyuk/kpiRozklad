//
//  DetailViewController.swift
//  kpiRozklad
//
//  Created by Denis on 9/25/19.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    var lesson: Datum? = nil
    @IBOutlet weak var lessonNameLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var teacherRatingLabel: UILabel!
    @IBOutlet weak var roomTypeLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeStartLabel: UILabel!
    @IBOutlet weak var timeEndLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let lesson = lesson else { return }
        var teacher: Teacher? = nil
        if lesson.teachers.count != 0 {
            teacher = lesson.teachers[0]
            teacherLabel.text = teacher?.teacherFullName
            teacherRatingLabel.text = teacher?.teacherRating
        }
        lessonNameLabel.text = lesson.lessonName
        roomTypeLabel.text = lesson.lessonType.rawValue + " " + lesson.lessonRoom
        
        dayLabel.text = lesson.dayName.rawValue
        timeStartLabel.text = "Початок: " + lesson.timeStart
        timeEndLabel.text = "Кінець: " + lesson.timeEnd
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
