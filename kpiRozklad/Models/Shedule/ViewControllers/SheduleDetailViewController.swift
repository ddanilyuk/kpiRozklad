//
//  DetailViewController.swift
//  kpiRozklad
//
//  Created by Denis on 9/25/19.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit
//import PanModal

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
    @IBOutlet weak var groupsLabel: UILabel!
    
    /// Big blue button to show Teacher Shedule
    @IBOutlet weak var checkTeacherShedule: UIButton!

    /// StackView it which all labels and button are located
    @IBOutlet weak var stackView: UIStackView!
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Деталі"

        getVariablesFromNavigationController()
        setupViews()
        setupButton()
    }
    
    
    private func setupViews() {
        guard let lesson = lesson else { return }
        
        lessonNameLabel.text = lesson.lessonName
        dayLabel.text = lesson.dayName.rawValue + ", " + lesson.lessonWeek + " тиждень"
        timeStartLabel.text = "Початок: " + lesson.timeStart
        timeEndLabel.text = "Кінець: " + lesson.timeEnd
        
        if lesson.lessonRoom == "" && lesson.lessonType == .empty {
            deleteFromStackView([roomTypeLabel])
        } else {
            roomTypeLabel.text = lesson.lessonType.rawValue + " " + lesson.lessonRoom
        }
        
        guard let teacher = lesson.teachers?.count != 0 ? lesson.teachers?[0] : nil else {
            checkTeacherShedule.isHidden = true
            groupsLabel.isHidden = true
            deleteFromStackView([teacherLabel, teacherRatingLabel, roomTypeLabel])
            return
        }
        self.teacher = teacher
        
        if teacher.teacherID == "" {
            deleteFromStackView([teacherLabel])
            checkTeacherShedule.isHidden = true
        }
        
        if teacher.teacherRating == "" {
            deleteFromStackView([teacherRatingLabel])
        }
        
        if teacher.teacherFullName != "" {
            teacherLabel.text = teacher.teacherFullName
        } else if teacher.teacherName != "" {
            teacherLabel.text = teacher.teacherName
        } else {
            teacherLabel.text = lesson.teacherName
        }
        
        teacherRatingLabel.text = "Рейтинг викладача: \(teacher.teacherRating)"
        
        if lesson.groups?.count == 0 || lesson.groups == nil {
            groupsLabel.text = " "
            getTeacherLessons(dayNumber: lesson.dayNumber, lessonNumber: lesson.lessonNumber, teacherID: teacher.teacherID, lessonWeek: lesson.lessonWeek)
            
        } else {
            groupsLabel.text = "Групи: \(getGroupsOfLessonString(lesson: lesson))"
            checkTeacherShedule.isHidden = (global.sheduleType == .teachers && teacher.teacherID == "") ? true : false
        }
    }
    
    
    private func setupButton() {
        checkTeacherShedule.layer.cornerRadius = 25
    }
    
    
    private func deleteFromStackView(_ views: [UIView]) {
        for view in views {
            view.isHidden = true
            stackView.removeArrangedSubview(view)
            stackView.addArrangedSubview(UIView())
        }
    }
    
    
    private func getVariablesFromNavigationController() {
        guard let navigationVC = self.navigationController as? SheduleDetailNavigationController else { return }
        self.lesson = navigationVC.lesson
        
    }
    
    
    // MARK: - prepare
    /// Seque to `TeacherSheduleViewController`
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTeacherSheduleFromDetail" {
            if let destination = segue.destination as? TeacherSheduleViewController {
                destination.teacher = self.teacher
            }
        }
    }
    
    
    func getGroups(dayNumber: String, lessonNumber: String, teacherID: String, lessonWeek: String, lessons: [Lesson]) {
        for lesson in lessons {
            if lesson.dayNumber == dayNumber &&
                lesson.lessonNumber == lessonNumber &&
                lesson.lessonWeek == lessonWeek {
                DispatchQueue.main.async {
                    self.groupsLabel.isHidden = false
                    self.groupsLabel.text = "Групи: \(getGroupsOfLessonString(lesson: lesson))"
                }
            }
        }
    }
    
    
    private func getTeacherLessons(dayNumber: String, lessonNumber: String, teacherID: String, lessonWeek: String) {
        API.getTeacherLessons(forTeacherWithId: Int(teacherID) ?? 0).done({ [weak self] (lessons) in
            self?.getGroups(dayNumber: dayNumber, lessonNumber: lessonNumber, teacherID: teacherID, lessonWeek: lessonWeek, lessons: lessons)
        }).catch({ [weak self] (error) in
            guard let this = self else { return }
            
            if error.localizedDescription != NetworkingApiError.lessonsNotFound.localizedDescription {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
                    this.getTeacherLessons(dayNumber: dayNumber, lessonNumber: lessonNumber, teacherID: teacherID, lessonWeek: lessonWeek)
                }
            }
        })
    }

}
