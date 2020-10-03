//
//  СolourPickerViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 14.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit


class ColourPickerViewController: UIViewController {

    /// Main picker
    @IBOutlet weak var colorPickerView: ColorPickerView!
    
    /// Main table view
    @IBOutlet weak var tableView: UITableView!
    
    /// Segment contoll which change current or next colour
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    /// Choosed colour of next cell
    var newCellNextColour: UIColor?
    
    /// Choosed colour of current cell
    var newCellCurrentColour: UIColor?
    
    /// Variable from `SettingTVC` (to set  default colour of `colorPickerView` )
    var defaultColour: UIColor?
    
    /// Settings singleton
    let settings = Settings.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButton()
        
        setupColourPickerView()
        
        setupTableView()
        
        setupSegmetControll()
        
        setLargeTitleDisplayMode(.never)
    }
        
    override func viewDidAppear(_ animated: Bool) {
        selectDefaultColour(cellType: .currentCell)
    }
    
    
    // MARK: - SETUP functions
    private func setupSegmetControll() {
        let titleTextAttributesSelected = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let titleTextAttributesNormal = [NSAttributedString.Key.foregroundColor: UIColor.systemBlue]

        segmentControl.setTitleTextAttributes(titleTextAttributesNormal, for: .normal)
        segmentControl.setTitleTextAttributes(titleTextAttributesSelected, for: .selected)
    }
    
    private func setupColourPickerView() {
        colorPickerView.delegate = self
        colorPickerView.layoutDelegate = self
        colorPickerView.isSelectedColorTappable = false
        colorPickerView.selectionStyle = .check
        colorPickerView.layoutSubviews()
    }
    
    private func setupTableView() {
        self.tableView.register(UINib(nibName: LessonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: LessonTableViewCell.identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isScrollEnabled = false
    }
    
    func setupButton() {
        let button = UIBarButtonItem(title: "Зберегти", style: .plain, target: self, action: #selector(show(sender:)))
        navigationItem.rightBarButtonItem = button
    }
    
    /**
     Function which call when user tap to save colour
     */
    @objc func show(sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: "Змінити колір поточної та наступної пари?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Змінити", style: .default, handler: { (_) in
            self.settings.cellNextColour = self.newCellNextColour ?? self.settings.cellNextColour
            self.settings.cellCurrentColour = self.newCellCurrentColour ?? self.settings.cellCurrentColour
            self.navigationController?.popViewController(animated: true)

        }))
        
        alert.addAction(UIAlertAction(title: "Скасувати", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     Segment controll changed
     */
    @IBAction func didChangeCellType(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            selectDefaultColour(cellType: .currentCell)
        case 1:
            selectDefaultColour(cellType: .nextCell)
        default:
            break
        }
    }
    
    /**
     Show the  default color in `colorPickerView`
     */
    func selectDefaultColour(cellType: SheduleCellType) {
        let index = findIndexOfDefaultСolour(cellType: cellType)

        if colorPickerView.indexOfSelectedColor != index {
            colorPickerView.selectColor(at: index, animated: true)
            colorPickerView.preselectedIndex = index
        }
    }
    
    /**
     Find index of user current or next colour
     */
    func findIndexOfDefaultСolour(cellType: SheduleCellType) -> Int {
        var colourToFind = UIColor.clear
        
        if cellType == .currentCell {
            colourToFind = settings.cellCurrentColour
        } else if cellType == .nextCell {
            colourToFind = settings.cellNextColour
        }
        
        var index = 0
        for i in 0..<colorPickerView.colors.count {
            let colour = colorPickerView.colors[i]
            if colour == colourToFind {
                index = i
                return index
            }
        }
        return index
    }
}


// MARK: - ColorPickerViewDelegate
extension ColourPickerViewController: ColorPickerViewDelegate {

    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
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
                newCellCurrentColour = backgroundColour
            } else if segmentControl.selectedSegmentIndex == 1 {
                newCellNextColour = backgroundColour
            }
            
            
            tableView.reloadData()
        }
    }
    
}
 

extension ColourPickerViewController: ColorPickerViewDelegateFlowLayout {
    
    func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
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
