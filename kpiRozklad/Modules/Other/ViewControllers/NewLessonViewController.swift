//
//  NewLessonViewController.swift
//  kpiRozklad
//
//  Created by Денис Данилюк on 17.07.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit

class NewLessonViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let headersOfSections: [Int: String] = [
        3: "Оберіть тип пари",
        4: "Оберіть тиждень",
        5: "Оберіть день та пару"
    ]
    
    let placeHoldersOfSections: [Int: String] = [
        0: "Назва",
        1: "Викладач",
        2: "Аудиторія",
        5: "День"
    ]
    
    var isDetailsOpen: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = tint
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = tint
        tableView.register(UINib(nibName: TextFieldNewLessonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: TextFieldNewLessonTableViewCell.identifier)
        tableView.register(UINib(nibName: LessonTypeAndWeekTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: LessonTypeAndWeekTableViewCell.identifier)
        tableView.register(UINib(nibName: CellWithOneSectionPickerTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: CellWithOneSectionPickerTableViewCell.identifier)
    }
}

extension NewLessonViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return isDetailsOpen ? 2 : 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return 150
        } else {
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 4
        }
        return headersOfSections[section] == nil ? 20 : 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headersOfSections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0...2, 5:
            if indexPath.row == 0 {
                guard let newLessonCell = tableView.dequeueReusableCell(withIdentifier: TextFieldNewLessonTableViewCell.identifier, for: indexPath) as? TextFieldNewLessonTableViewCell else { return UITableViewCell() }
                newLessonCell.configureCell(placeholder: placeHoldersOfSections[indexPath.section])
                return newLessonCell
            } else {
                guard let cellWithOnePicker = tableView.dequeueReusableCell(withIdentifier: CellWithOneSectionPickerTableViewCell.identifier, for: indexPath) as? CellWithOneSectionPickerTableViewCell else { return UITableViewCell() }
                return cellWithOnePicker
            }
            
        case 3, 4:
            guard let lessonTypeCell = tableView.dequeueReusableCell(withIdentifier: LessonTypeAndWeekTableViewCell.identifier, for: indexPath) as? LessonTypeAndWeekTableViewCell else { return UITableViewCell() }
            if indexPath.section == 3 {
                lessonTypeCell.cellType = .lessonType
            } else if indexPath.section == 4 {
                lessonTypeCell.cellType = .week
            }
            return lessonTypeCell
            
        default:
            let cell = UITableViewCell(style: .default, reuseIdentifier: "")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            if !isDetailsOpen {
                tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            } else {
                tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            }
            isDetailsOpen.toggle()
        }
    }
    
    
}
