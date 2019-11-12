//
//  DetailViewController.swift
//  kpiRozklad
//
//  Created by Denis on 9/25/19.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

class SheduleDetailViewController: UIViewController {

    
    var lesson: Lesson? = nil
    @IBOutlet weak var lessonNameLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var teacherRatingLabel: UILabel!
    @IBOutlet weak var roomTypeLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeStartLabel: UILabel!
    @IBOutlet weak var timeEndLabel: UILabel!
    
    @IBOutlet weak var checkTeacherShedule: UIButton!
    var teacher: Teacher? = nil

    @IBOutlet weak var stackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let lesson = lesson else { return }
            if lesson.teachers.count != 0 {
                teacher = lesson.teachers[0]
                if teacher?.teacherFullName != ""{
                    teacherLabel.text = teacher?.teacherFullName
                } else {
                    teacherLabel.text = teacher?.teacherName
                }
                teacherRatingLabel.text = teacher?.teacherRating
        }
        print(lesson)
        lessonNameLabel.text = lesson.lessonName
        roomTypeLabel.text = lesson.lessonType.rawValue + " " + lesson.lessonRoom
        
        dayLabel.text = lesson.dayName.rawValue + ", " + lesson.lessonWeek + " тиждень"
        timeStartLabel.text = "Початок: " + lesson.timeStart
        timeEndLabel.text = "Кінець: " + lesson.timeEnd
        
        // Todo:- check corner radius
        checkTeacherShedule.layer.cornerRadius = 25
        
    }
    
    @IBAction func didPressCheckTeacherShedule(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showTeacherShedule" {
            if let destination = segue.destination as? TeacherSheduleViewController {
                destination.teacher = self.teacher
                    
            }
        }
    }


}
