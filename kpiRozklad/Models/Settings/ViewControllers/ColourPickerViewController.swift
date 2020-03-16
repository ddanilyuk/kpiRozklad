//
//  СolourPickerViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 14.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

enum CellType {
    case current
    case next
}

class ColourPickerViewController: UIViewController {

    @IBOutlet weak var colorPickerView: ColorPickerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var defaultColour: UIColor?
    let settings = Settings.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        
        colorPickerView.delegate = self
        colorPickerView.layoutDelegate = self
        colorPickerView.isSelectedColorTappable = false
        colorPickerView.selectionStyle = .check
        colorPickerView.layoutSubviews()
//        colorPickerView.selectColor(at: 2, animated: true)
        
        self.tableView.register(UINib(nibName: LessonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: LessonTableViewCell.identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isScrollEnabled = false
        
//        guard let defaultColour = defaultColour else {
//            return
//        }
//
//        self.tableView.backgroundColor = defaultColour
//        self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        guard let defaultColour = defaultColour else {
//            return
//        }
//        self.tableView.backgroundColor = defaultColour
//
//        colorPickerView.layoutSubviews()
//
//
//        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? LessonTableViewCell {
//
//
//            let textColour: UIColor = defaultColour.isWhiteText ? .white : .black
//
//            cell.startLabel.textColor = textColour
//
//            cell.endLabel.textColor = textColour
//
//            cell.teacherLabel.textColor = textColour
//
//            cell.roomLabel.textColor = textColour
//
//            cell.lessonLabel.textColor = textColour
//
//
//            cell.backgroundColor = defaultColour
//
//        }
//        self.tableView.reloadData()

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        selectDefaultColour(cellType: .current)
    }
    
    
    @IBAction func didChangeCellType(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            selectDefaultColour(cellType: .current)
//            colorPickerView.reloadInputViews()
            
//            for i in 0..<colorPickerView.colors.count {
//                let index = IndexPath(row: i, section: 0)
//                guard let cell = colorPickerView?.collectionView.cellForItem(at: index) as? ColorPickerCell else {
//                    return
//                }
//                if selectionStyle == .check {
//                    cell.checkbox.setCheckState(.unchecked, animated: true)
//                }
//            }
            
        case 1:
            selectDefaultColour(cellType: .next)
            colorPickerView.reloadInputViews()
        default: break
            
        }
    }
    
    
    func selectDefaultColour(cellType: CellType) {
        let index = findIndexOfDefaultСolour(cellType: cellType)

        if colorPickerView.indexOfSelectedColor != index {
            colorPickerView.selectColor(at: index, animated: true)
//            colorPickerView.layoutSubviews()
        }
    }
    
    
    func findIndexOfDefaultСolour(cellType: CellType) -> Int {
        var colourToFind = UIColor.clear
        
        if cellType == .current {
            colourToFind = settings.cellCurrentColour
        } else if cellType == .next {
            colourToFind = settings.cellNextColour
        }
        
        var index = 0
        for i in 0..<colorPickerView.colors.count {
            let colour = colorPickerView.colors[i]
            if colour == colourToFind {
                index = i
            }
        }
        
        return index

    }
    
    @IBAction func didPressSave(_ sender: UIButton) {
    }
    

}

// MARK: - ColorPickerViewDelegate
extension ColourPickerViewController: ColorPickerViewDelegate {

    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        // A color has been selected
//        tableView.backgroundColor = colorPickerView.colors[indexPath.row]
//        colorPickerView.reloadInputViews()
//        colorPickerView.layoutSubviews()
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? LessonTableViewCell {
            let backgroundColour: UIColor = colorPickerView.colors[indexPath.row]
            
            let textColour: UIColor = backgroundColour.isWhiteText ? .white : .black
            
            cell.startLabel.textColor = textColour
            cell.endLabel.textColor = textColour
            cell.teacherLabel.textColor = textColour
            cell.roomLabel.textColor = textColour
            cell.lessonLabel.textColor = textColour
            cell.backgroundColor = backgroundColour
            
            self.tableView.backgroundColor = backgroundColour
            
            if segmentControl.selectedSegmentIndex == 0 {
                settings.cellCurrentColour = backgroundColour
            } else if segmentControl.selectedSegmentIndex == 1 {
                settings.cellNextColour = backgroundColour
            }
            
            
            tableView.reloadData()
        }
    }
    
    

//      // This is an optional method
//      func colorPickerView(_ colorPickerView: ColorPickerView, didDeselectItemAt indexPath: IndexPath) {
//
//      }

}
 
extension ColourPickerViewController: ColorPickerViewDelegateFlowLayout {
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return (screenWidth - 8)
        return 20
    }
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}


extension ColourPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LessonTableViewCell.identifier, for: indexPath) as? LessonTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.startLabel.text = "10:25"
        
        cell.endLabel.text = "12:20"
        
        cell.teacherLabel.text = "Викладач"
        
        cell.roomLabel.text = "301-18"
        
        cell.lessonLabel.text = "Предмет"
        
        cell.timeLeftLabel.text = ""
        
        if let defaultColour = defaultColour {

            cell.backgroundColor = defaultColour
            tableView.backgroundColor = defaultColour
            
            let textColour: UIColor = defaultColour.isWhiteText ? .white : .black
            
            cell.startLabel.textColor = textColour
            cell.endLabel.textColor = textColour
            cell.teacherLabel.textColor = textColour
            cell.roomLabel.textColor = textColour
            cell.lessonLabel.textColor = textColour
            self.defaultColour = nil
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    
    
}
