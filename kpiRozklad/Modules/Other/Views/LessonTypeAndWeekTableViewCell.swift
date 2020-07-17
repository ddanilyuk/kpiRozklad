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

class LessonTypeAndWeekTableViewCell: UITableViewCell {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var cellType: LessonTypeAndWeekTableViewCellType = .lessonType {
        didSet {
            setupSegmentControl()
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        setupSegmentControl()
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
//            segmentControl.setTitle("Лек", forSegmentAt: 0)
//            segmentControl.setTitle("Лаб", forSegmentAt: 1)
//            segmentControl.setTitle("Прак", forSegmentAt: 2)
//            segmentControl.setTitle("Інше", forSegmentAt: 3)
        case .week:
            segmentControl.insertSegment(withTitle: "1 тиждень", at: 0, animated: false)
            segmentControl.insertSegment(withTitle: "2 тиждень", at: 1, animated: false)
            segmentControl.selectedSegmentIndex = 0
            
//            segmentControl.setTitle("1 тиждень", forSegmentAt: 0)
//            segmentControl.setTitle("2 тиждень", forSegmentAt: 1)
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}


