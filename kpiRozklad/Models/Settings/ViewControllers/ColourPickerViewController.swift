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
    
    var newCellNextColour: UIColor?
    var newCellCurrentColour: UIColor?
    
    var defaultColour: UIColor?
    let settings = Settings.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
        setupNavigation()
        setupColourPickerView()
        setupTableView()
        setLargeTitleDisplayMode(.never)

    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//
//
//        if self.isMovingFromParent {
//            // Your code...
//            let alert = UIAlertController(title: nil, message: "Застосувати зміни?", preferredStyle: .actionSheet)
//
//            alert.addAction(UIAlertAction(title: "Так", style: .default, handler: { (_) in
//
//                self.settings.cellNextColour = self.newCellNextColour ?? self.settings.cellNextColour
//                self.settings.cellCurrentColour = self.newCellCurrentColour ?? self.settings.cellCurrentColour
//
//            }))
//
//            alert.addAction(UIAlertAction(title: "Вийти", style: .default, handler: { (_) in
//
//                self.navigationController?.popViewController(animated: true)
//            }))
//
//            if (settings.cellNextColour != newCellNextColour ?? self.settings.cellNextColour) || (settings.cellCurrentColour != newCellCurrentColour ?? self.settings.cellCurrentColour) {
//                self.present(alert, animated: true, completion: {
//                })
//            }
//        }
//    }
    
//    override func didMove(toParent parent: UIViewController?) {
//        super.didMove(toParent: parent)
//
//        if parent == nil {
//            let alert = UIAlertController(title: nil, message: "Застосувати зміни?", preferredStyle: .actionSheet)
//
//            alert.addAction(UIAlertAction(title: "Так", style: .default, handler: { (_) in
//
//                self.settings.cellNextColour = self.newCellNextColour ?? self.settings.cellNextColour
//                self.settings.cellCurrentColour = self.newCellCurrentColour ?? self.settings.cellCurrentColour
//
//            }))
//
//            alert.addAction(UIAlertAction(title: "Вийти", style: .default, handler: { (_) in
//
//                self.navigationController?.popViewController(animated: true)
//            }))
//
//            if (settings.cellNextColour != newCellNextColour ?? self.settings.cellNextColour) || (settings.cellCurrentColour != newCellCurrentColour ?? self.settings.cellCurrentColour) {
//
//                parent?.present(alert, animated: true, completion: {
//                })
//            }
//        }
//    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//
//
//
//        let alert = UIAlertController(title: nil, message: "Застосувати зміни?", preferredStyle: .actionSheet)
//
//        alert.addAction(UIAlertAction(title: "Так", style: .default, handler: { (_) in
//
//            self.settings.cellNextColour = self.newCellNextColour ?? self.settings.cellNextColour
//            self.settings.cellCurrentColour = self.newCellCurrentColour ?? self.settings.cellCurrentColour
//
//        }))
//
//        alert.addAction(UIAlertAction(title: "Вийти", style: .default, handler: { (_) in
//
//            self.navigationController?.popViewController(animated: true)
//        }))
//
//        if (settings.cellNextColour != newCellNextColour ?? self.settings.cellNextColour) || (settings.cellCurrentColour != newCellCurrentColour ?? self.settings.cellCurrentColour) {
//            self.present(alert, animated: true, completion: {
//            })
//        }
//
//    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        let alert = UIAlertController(title: nil, message: "Застосувати зміни?", preferredStyle: .actionSheet)
//
//        alert.addAction(UIAlertAction(title: "Так", style: .default, handler: { (_) in
//
//            self.settings.cellNextColour = self.newCellNextColour ?? self.settings.cellNextColour
//            self.settings.cellCurrentColour = self.newCellCurrentColour ?? self.settings.cellCurrentColour
//
//        }))
//
//        alert.addAction(UIAlertAction(title: "Вийти", style: .default, handler: { (_) in
//        }))
//
//        if (settings.cellNextColour != newCellNextColour ?? self.settings.cellNextColour) || (settings.cellCurrentColour != newCellCurrentColour ?? self.settings.cellCurrentColour) {
//            self.present(alert, animated: true, completion: {
//            })
//        }
//    }
    
    
    private func setupNavigation() {
//        self.navigationController?.navigationBar.prefersLargeTitles = true
//        self.navigationItem.largeTitleDisplayMode = .never
//        self.navigationController?.navigationItem.largeTitleDisplayMode = .never
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
    
    @objc func show(sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: "Змінити колір поточної та наступної пари?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Змінити", style: .default, handler: { (_) in
            
            self.settings.cellNextColour = self.newCellNextColour ?? self.settings.cellNextColour
            self.settings.cellCurrentColour = self.newCellCurrentColour ?? self.settings.cellCurrentColour
            self.navigationController?.popViewController(animated: true)

        }))
        
        alert.addAction(UIAlertAction(title: "Скасувати", style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion: {
        })
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        selectDefaultColour(cellType: .current)
    }
    
    
    @IBAction func didChangeCellType(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            selectDefaultColour(cellType: .current)
        case 1:
            selectDefaultColour(cellType: .next)
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
                newCellCurrentColour = backgroundColour
            } else if segmentControl.selectedSegmentIndex == 1 {
                newCellNextColour = backgroundColour
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
