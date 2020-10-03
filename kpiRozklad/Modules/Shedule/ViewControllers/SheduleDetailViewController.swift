//
//  DetailViewController.swift
//  kpiRozklad
//
//  Created by Denis on 9/25/19.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit


class SheduleDetailViewController: UIViewController {
    
    /// Variable FROM seque
    var lesson: Lesson? = nil

    /// Variable FOR seque to `TeacherSheduleViewController`
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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewWithActivityIndicator: UIView!
    
    /// Big blue button to show Teacher Shedule
    @IBOutlet weak var checkTeacherShedule: UIButton!

    /// StackView it which all labels and button are located
    @IBOutlet weak var stackView: UIStackView!
    
    var settings = Settings.shared
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Деталі"
        
        /// Getting lessons from `SheduleViewController`
        getVariablesFromNavigationController()
        
        /// Setup all views in stack view
        setupViews()
 
        ///Setup groups loading activity indicator
        setupActivityIndicator()
    }
    
    private func setupViews() {
        /// LESSON
        guard let lesson = lesson else { return }
        
        lessonNameLabel.text = lesson.lessonName
        dayLabel.text = lesson.dayName.rawValue + ", " + lesson.lessonWeek.rawValue + " тиждень"
        timeStartLabel.text = "Початок: " + lesson.timeStart
        timeEndLabel.text = "Кінець: " + lesson.timeEnd
        
        if lesson.lessonRoom == "" && lesson.lessonType == .empty {
            deleteFromStackView([roomTypeLabel])
        } else {
            roomTypeLabel.text = lesson.lessonType.rawValue + " " + lesson.lessonRoom
        }
        
        /// TEACHER
        guard let teacher = lesson.teacher else {
            checkTeacherShedule.isHidden = true
            groupsLabel.isHidden = true
            viewWithActivityIndicator.isHidden = true
            deleteFromStackView([teacherLabel, teacherRatingLabel, roomTypeLabel])
            return
        }
        self.teacher = teacher
        
        if teacher.teacherID == 0 {
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
        
        /// GROUPS
        if lesson.groups?.count == 0 || lesson.groups == nil {
            getTeacherLessons(dayNumber: lesson.dayNumber, lessonNumber: lesson.lessonNumber, teacherID: teacher.teacherID, lessonWeek: lesson.lessonWeek, lessonId: lesson.id)
            
        } else {
            groupsLabel.text = "Групи: \(lesson.getGroupsOfLessonInString())"
            checkTeacherShedule.isHidden = (settings.sheduleType == .teachers && teacher.teacherID == 0) ? true : false
            viewWithActivityIndicator.isHidden = true
        }
    }
    
    /// SetupActivityIndicator
    private func setupActivityIndicator() {
        activityIndicator.startAndShow()
    }
    
    /**
     Delete array of views from `stackView`

     - Parameter views: Views to delete
     */
    private func deleteFromStackView(_ views: [UIView]) {
        for view in views {
            view.isHidden = true
            stackView.removeArrangedSubview(view)
            stackView.addArrangedSubview(UIView())
        }
    }
    
    /**
     Get lessons from `SheduleVC` -> `SheduleDetailNaviagationC`
     */
    private func getVariablesFromNavigationController() {
        guard let navigationVC = self.navigationController as? SheduleDetailNavigationController else { return }
        self.lesson = navigationVC.lesson
    }
    
    /**
     Pushing `teacher`  to `SheduleViewController`
     */
    @IBAction func didPressGetTeacherShedule(_ sender: UIButton) {
        guard let sheduleVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: SheduleViewController.identifier) as? SheduleViewController else { return }
        
        sheduleVC.isTeachersShedule = true
        sheduleVC.teacherFromSegue = teacher
        settings.isTryToRefreshShedule = true
        
        navigationController?.pushViewController(sheduleVC, animated: true)
    }
    
    /**
     Search for a lesson that is shown in detail  in `getTeacherLessons()`  response

     - Parameter dayNumber: lesson to find dayNumber
     - Parameter lessonNumber: lesson to find lessonNumber
     - Parameter teacherID: lesson to find teacherID
     - Parameter lessonWeek: lesson to find lessonWeek
     - Parameter lessons: array of lessons from `getTeacherLessons()`  response
     - Parameter lessonId: used when lesson were edited
    
    */
    func getGroups(dayNumber: Int, lessonNumber: Int, teacherID: Int, lessonWeek: WeekType, lessons: [Lesson], lessonId: Int) {
        for lesson in lessons {
            if lesson.dayNumber == dayNumber &&
               lesson.lessonNumber == lessonNumber &&
               lesson.lessonWeek == lessonWeek {
                DispatchQueue.main.async {
                    self.viewWithActivityIndicator.isHidden = true
                    self.groupsLabel.text = "Групи: \(lesson.getGroupsOfLessonInString())"
                }
                break

            }
        }
        /// If lesson were edited, try to finf lesson by `id`
        for lesson in lessons {
            if lesson.id == lessonId {
                DispatchQueue.main.async {
                    self.viewWithActivityIndicator.isHidden = true
                    self.groupsLabel.text = "Групи: \(lesson.getGroupsOfLessonInString())"
                }
                break
            }
        }
    }
    
    /**
     Server Request to get lessons and then `getGroups()`
     */
    private func getTeacherLessons(dayNumber: Int, lessonNumber: Int, teacherID: Int, lessonWeek: WeekType, lessonId: Int) {
        API.getTeacherLessons(forTeacherWithId: teacherID).done({ [weak self] (lessons) in
            self?.getGroups(dayNumber: dayNumber, lessonNumber: lessonNumber, teacherID: teacherID, lessonWeek: lessonWeek, lessons: lessons, lessonId: lessonId)
        }).catch({ [weak self] (error) in
            guard let this = self else { return }
            
            if error.localizedDescription != NetworkingApiError.lessonsNotFound.localizedDescription {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
                    this.getTeacherLessons(dayNumber: dayNumber, lessonNumber: lessonNumber, teacherID: teacherID, lessonWeek: lessonWeek, lessonId: lessonId)
                }
            }
        })
    }
}
