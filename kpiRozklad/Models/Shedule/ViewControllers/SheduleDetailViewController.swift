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
        
        getVariablesFromNavigationController()
        self.title = "Деталі"
        
        /// Guarding lesson
        guard let lesson = lesson else { return }
        
        
        if lesson.teachers?.count != 0 {
            teacher = lesson.teachers?[0]
            if teacher?.teacherID == "" {
                teacherLabel.isHidden = true
                teacherRatingLabel.isHidden = true
                groupsLabel.isHidden = true
                
                stackView.removeArrangedSubview(teacherLabel)
                stackView.removeArrangedSubview(teacherRatingLabel)
                stackView.removeArrangedSubview(groupsLabel)
                
                stackView.addArrangedSubview(UIView())
                stackView.addArrangedSubview(UIView())
                stackView.addArrangedSubview(UIView())

                checkTeacherShedule.isEnabled = false
                checkTeacherShedule.backgroundColor = .lightGray
                checkTeacherShedule.borderColor = .lightGray
            }
            
            if lesson.lessonRoom == "" && lesson.lessonType == .empty {
                stackView.removeArrangedSubview(roomTypeLabel)
                stackView.addArrangedSubview(UIView())
            }
            
            
            if teacher?.teacherFullName != "" {
                teacherLabel.text = teacher?.teacherFullName
            } else if teacher?.teacherName != "" {
                teacherLabel.text = teacher?.teacherName
            } else {
                teacherLabel.text = lesson.teacherName
            }
            
            if let rating = teacher?.teacherRating {
                teacherRatingLabel.text = rating != "" ? "Рейтинг викладача: \(rating)" : ""
                if rating == "" {
                    if !teacherLabel.isHidden {
                        stackView.removeArrangedSubview(teacherRatingLabel)
                        stackView.addArrangedSubview(UIView())
                    }
                    
                }
            }
            
        }
        
        lessonNameLabel.text = lesson.lessonName
        roomTypeLabel.text = lesson.lessonType.rawValue + " " + lesson.lessonRoom
        
        dayLabel.text = lesson.dayName.rawValue + ", " + lesson.lessonWeek + " тиждень"
        timeStartLabel.text = "Початок: " + lesson.timeStart
        timeEndLabel.text = "Кінець: " + lesson.timeEnd
        
        
        checkTeacherShedule.layer.cornerRadius = 25
        
        if lesson.groups?.count == 0 {
            getTeacherLessons(dayNumber: lesson.dayNumber, lessonNumber: lesson.lessonNumber, teacherID: teacher?.teacherID ?? "0", lessonWeek: lesson.lessonWeek)
        } else {
            self.groupsLabel.text = "Групи: \(getGroupsOfLessonString(lesson: lesson))"
        }
        
        // TODO: - подивитись на розклад групи
        if global.sheduleType == .teachers {
            self.groupsLabel.text = "Групи: \(getGroupsOfLessonString(lesson: lesson))"
            checkTeacherShedule.isHidden = true
//            stackView.removeArrangedSubview(checkTeacherShedule)
            
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
                    self.groupsLabel.text = "Групи: \(getGroupsOfLessonString(lesson: lesson))"
                }
            }
        }
    }
    
    
//    // MARK: - server
//    func server(dayNumber: String, lessonNumber: String, teacherID: String, lessonWeek: String) {
//
//        var lessons: [Lesson] = []
//
//        guard var url = URL(string: "https://api.rozklad.org.ua/v2/teachers/") else { return }
//        url.appendPathComponent(teacherID)
//        url.appendPathComponent("/lessons")
//        print(url)
//        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
//            guard let data = data else { return }
//            let decoder = JSONDecoder()
//
//            do {
//                if let error = try? decoder.decode(Error.self, from: data) {
//                    if error.message == "Lessons not found" {
//
//                    }
//                }
//
//                guard let serverFULLDATA = try? decoder.decode(WelcomeLessons.self, from: data) else { return }
//                lessons = serverFULLDATA.data
//                self.getGroups(dayNumber: dayNumber, lessonNumber: lessonNumber, teacherID: teacherID, lessonWeek: lessonWeek, lessons: lessons)
//            }
//        }
//        task.resume()
//
//    }
    
    
    private func getTeacherLessons(dayNumber: String, lessonNumber: String, teacherID: String, lessonWeek: String) {
        API.getTeacherLessons(forTeacherWithId: Int(teacherID) ?? 0).done({ [weak self] (lessons) in
            self?.getGroups(dayNumber: dayNumber, lessonNumber: lessonNumber, teacherID: teacherID, lessonWeek: lessonWeek, lessons: lessons)
        }).catch({ [weak self] (error) in
            guard let this = self else { return }
            
            if error.localizedDescription != NetworkingApiError.lessonsNotFound.localizedDescription {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                    this.getTeacherLessons(dayNumber: dayNumber, lessonNumber: lessonNumber, teacherID: teacherID, lessonWeek: lessonWeek)
                }
            }
        })
    }

}
