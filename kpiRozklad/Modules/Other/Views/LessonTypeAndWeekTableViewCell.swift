//
//  LessonTypeTableViewCell.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 17.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


enum LessonTypeAndWeekTableViewCellType {
    case lessonType
    case week
}


protocol LessonTypeAndWeekTableViewCellDelegate {
    func weekSelected(week: WeekType)
    func typeSelected(type: LessonType)
}

class LessonTypeAndWeekTableViewCell: UITableViewCell {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var delegate: LessonTypeAndWeekTableViewCellDelegate?
    
    var cellType: LessonTypeAndWeekTableViewCellType = .lessonType {
        didSet {
            setupSegmentControl()
        }
    }
    
    var selectedWeek: WeekType = .first {
        didSet {
            if cellType == .week {
                segmentControl.selectedSegmentIndex = selectedWeek == .first ? 0 : 1
                print(selectedWeek)
                delegate?.weekSelected(week: selectedWeek)
            }
        }
    }
    
    var selectedType: LessonType = .empty {
        didSet {
            if cellType == .lessonType {
                if selectedType == .лек1 {
                    segmentControl.selectedSegmentIndex = 0
                } else if selectedType == .лаб {
                    segmentControl.selectedSegmentIndex = 1
                } else if selectedType == .прак {
                    segmentControl.selectedSegmentIndex = 2
                } else {
                    segmentControl.selectedSegmentIndex = 3
                }
                delegate?.typeSelected(type: selectedType)
            }
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSegmentControl()
    }
    
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            if cellType == .lessonType {
                selectedType = .лек1
            } else if cellType == .week {
                selectedWeek = .first
            }
        case 1:
            if cellType == .lessonType {
                selectedType = .лаб
            } else if cellType == .week {
                selectedWeek = .second
            }
        case 2:
            selectedType = .прак
        case 3:
            selectedType = .empty
        default:
            break
        }
    }
    

    private func setupSegmentControl() {
        // Appearance
        var titleTextAttributesNormal = [
            NSAttributedString.Key.foregroundColor: UIColor.blue,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
        ]
        let titleTextAttributesSelected = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
        ]
        
        if #available(iOS 13.0, *) {
            titleTextAttributesNormal = [NSAttributedString.Key.foregroundColor: UIColor.link]
        }
        
        segmentControl.setTitleTextAttributes(titleTextAttributesNormal, for: .normal)
        segmentControl.setTitleTextAttributes(titleTextAttributesSelected, for: .selected)
        
        if #available(iOS 13.0, *) {
            segmentControl.selectedSegmentTintColor = .link
        } else {
//            segmentControl.selectedSegmentTintColor = .blue
        }
        
        // Content
        segmentControl.removeAllSegments()
        
        switch cellType {
        case .lessonType:
            segmentControl.insertSegment(withTitle: "Лек", at: 0, animated: false)
            segmentControl.insertSegment(withTitle: "Лаб", at: 1, animated: false)
            segmentControl.insertSegment(withTitle: "Прак", at: 2, animated: false)
            segmentControl.insertSegment(withTitle: "Інше", at: 3, animated: false)
            segmentControl.selectedSegmentIndex = 0
        case .week:
            segmentControl.insertSegment(withTitle: "1 тиждень", at: 0, animated: false)
            segmentControl.insertSegment(withTitle: "2 тиждень", at: 1, animated: false)
            segmentControl.selectedSegmentIndex = 0
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}


