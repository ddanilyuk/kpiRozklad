//
//  lessonTableViewCell.swift
//  kpiRozklad
//
//  Created by Denis on 9/26/19.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

class LessonTableViewCell: UITableViewCell {

    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var lessonLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lessonLabel.text = nil
        self.backgroundColor = .none
    }
    
    func setupCell(with lesson: Lesson, type: SheduleCellType) {
        self.lessonLabel.text = lesson.lessonName
        self.teacherLabel.text = lesson.teacherName != "" ? lesson.teacherName : " "
        
        self.startLabel.textColor = colourTextLabel
        self.endLabel.textColor = colourTextLabel
        self.teacherLabel.textColor = colourTextLabel
        self.roomLabel.textColor = colourTextLabel
        self.lessonLabel.textColor = colourTextLabel
        self.startLabel.text = lesson.timeStart.stringTime
        self.endLabel.text = lesson.timeEnd.stringTime
        self.roomLabel.text = lesson.lessonType.rawValue + " " + lesson.lessonRoom
        self.timeLeftLabel.text = ""
        
        var textColor: UIColor = .clear
        
        switch type {
        case .defaultCell:
            self.backgroundColor = cellBackgroundColor
            if #available(iOS 13.0, *) {
                textColor = .label
            } else {
                textColor = .black
            }
        case .currentCell:
            self.backgroundColor = Settings.shared.cellCurrentColour
            textColor = self.backgroundColor?.isWhiteText ?? true ? .white : .black
        case .nextCell:
            self.backgroundColor = Settings.shared.cellNextColour
            textColor = self.backgroundColor?.isWhiteText ?? true ? .white : .black
        }
                
        self.startLabel.textColor = textColor
        self.endLabel.textColor = textColor
        self.teacherLabel.textColor = textColor
        self.roomLabel.textColor = textColor
        self.lessonLabel.textColor = textColor
        self.timeLeftLabel.textColor = textColor
    }
    
}
