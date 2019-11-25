//
//  DetailViewController.swift
//  kpiRozklad
//
//  Created by Denis on 9/25/19.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

class SheduleDetailViewController: UIViewController {

    /// Variable from seque
    var lesson: Lesson? = nil

    /// Variable for seque to `TeacherSheduleViewController`
    var teacher: Teacher? = nil

    /// Labels from Stroryboard
    @IBOutlet weak var lessonNameLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var teacherRatingLabel: UILabel!
    @IBOutlet weak var roomTypeLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeStartLabel: UILabel!
    @IBOutlet weak var timeEndLabel: UILabel!
    
    /// Big blue button to show Teacher Shedule
    @IBOutlet weak var checkTeacherShedule: UIButton!

    
    /// StackView it which all labels and button are located
    @IBOutlet weak var stackView: UIStackView!
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Guarding lesson
        guard let lesson = lesson else { return }
        
        if lesson.teachers.count != 0 {
            teacher = lesson.teachers[0]
            
            if teacher?.teacherFullName != "" {
                teacherLabel.text = teacher?.teacherFullName
            } else {
                teacherLabel.text = teacher?.teacherName
            }
            
            teacherRatingLabel.text = teacher?.teacherRating
        }
        
        lessonNameLabel.text = lesson.lessonName
        roomTypeLabel.text = lesson.lessonType.rawValue + " " + lesson.lessonRoom
        
        dayLabel.text = lesson.dayName.rawValue + ", " + lesson.lessonWeek + " тиждень"
        timeStartLabel.text = "Початок: " + lesson.timeStart
        timeEndLabel.text = "Кінець: " + lesson.timeEnd
        
        checkTeacherShedule.layer.cornerRadius = 25
    }
    
    
    // MARK: - prepare
    /// Seque to `TeacherSheduleViewController`
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTeacherShedule" {
            if let destination = segue.destination as? TeacherSheduleViewController {
                destination.teacher = self.teacher
            }
        }
    }
}
