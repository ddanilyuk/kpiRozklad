//
//  СolourPickerViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 14.03.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

class ColourPickerViewController: UIViewController {

    @IBOutlet weak var colorPickerView: ColorPickerView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var defaultColour: UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        
        colorPickerView.delegate = self
        colorPickerView.layoutDelegate = self
//        colorPickerView.selectColor(at: 2, animated: true)
        colorPickerView.reloadInputViews()
        
        self.tableView.register(UINib(nibName: LessonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: LessonTableViewCell.identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.isScrollEnabled = false
        
        guard let defaultColour = defaultColour else {
            return
        }
        
        self.tableView.backgroundColor = defaultColour
        self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        guard let defaultColour = defaultColour else {
//            return
//        }
//        self.tableView.backgroundColor = defaultColour
//        self.tableView.reloadData()
////        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? LessonTableViewCell {
////
////            cell.backgroundColor = defaultColour
////
////            tableView.reloadData()
////        }
//    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        var index = 0
        for i in 0..<colorPickerView.colors.count {
            let colour = colorPickerView.colors[i]
            if colour == Settings.shared.cellColour {
                index = i
            }
        }
        if colorPickerView.indexOfSelectedColor != index {
            colorPickerView.selectColor(at: index, animated: true)
        }
    }
    
    @IBAction func didChangeCellType(_ sender: UISegmentedControl) {
    }
    
    @IBAction func didPressSave(_ sender: UIButton) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

}

// MARK: - ColorPickerViewDelegate
extension ColourPickerViewController: ColorPickerViewDelegate {

    func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        // A color has been selected
//        tableView.backgroundColor = colorPickerView.colors[indexPath.row]
        
        
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
            
            Settings.shared.cellColour = backgroundColour
            
            tableView.reloadData()
        }
    }
    
    

      // This is an optional method
      func colorPickerView(_ colorPickerView: ColorPickerView, didDeselectItemAt indexPath: IndexPath) {
        // A color has been deselected
        
//        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TableViewCell {
//            if colorPickerView.colors[indexPath.row] == cell.backgroundColor {
//                cell.backgroundColor = .white
//
//                cell.timeStartLabel?.textColor = .black
//                cell.teacherNameLabel.textColor = .black
//
//                cell.roomLabel.textColor = .black
//                cell.timeEndLabel.textColor = .black
//                cell.lessonNameLabel.textColor = .black
//
//
//                tableView.reloadData()
//            }
//
//
//        }
      }

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
//        cell.backgroundColor =
        
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
