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
    
    @IBOutlet weak var whenLabel: WKInterfaceLabel!
    
    var timer: Timer?

    
    var lesson: Lesson? {
        didSet {
            guard let lesson = lesson else { return }
            self.lessonNameLabel.setText(lesson.lessonName)
            self.lessonRoomLabel.setText("\(lesson.lessonRoom) \(lesson.lessonType.rawValue)")
            self.timeStartLabel.setText(String(lesson.timeStart.stringTime))
            self.timeEndLabel.setText(String(lesson.timeEnd.stringTime))
            self.whenLabel.setText(self.getTextFromLessonTime(lesson: lesson))

            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                self?.whenLabel.setText(self?.getTextFromLessonTime(lesson: lesson))
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func getTextFromLessonTime(lesson: Lesson) -> String {
        let date = Date()
        let (dateStart, dateEnd) = getDateStartAndEnd(of: lesson)
        var (dayNumberFromCurrentDate, currentWeekFromTodayDate) = getCurrentWeekAndDayNumber(date: date)
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm:ss"
//
        if lesson.dayNumber != dayNumberFromCurrentDate {
            if lesson.lessonWeek != currentWeekFromTodayDate {
                dayNumberFromCurrentDate = dayNumberFromCurrentDate - 7
            }
            if lesson.dayNumber - dayNumberFromCurrentDate == 1 {
                return "завтра"
            } else if lesson.dayNumber - dayNumberFromCurrentDate == 2 {
                return "післязавтра"
            } else {
                return "через \(abs(lesson.dayNumber - dayNumberFromCurrentDate)) дні"
            }
        } else {
            if dateStart > date {
                return "через " + timeIntervalToString(dateStart.timeIntervalSinceNow)
            } else if dateStart <= date && dateEnd > date {
                return "ще " + timeIntervalToString(dateEnd.timeIntervalSinceNow)
            }
        }
        
        return "закінчилося"
    }
    
    func timeIntervalToString(_ timeInterval: TimeInterval) -> String {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "uk")
        
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        
        guard let formattedString = formatter.string(from: timeInterval) else { return "" }
        return formattedString
    }
}
