//
//  TeachersViewController.swift
//  kpiRozklad
//
//  Created by Denis on 26.10.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

class TeachersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let reuseID = "reuseIDForTeachers"
    
    var teachers = [Teacher]()
    var myTeachers = [Teacher]()
    var allTeachers = [Teacher]()
    
    var isChoosenMyTeachers: Bool = true
    
    var isSearching = false
    let search = UISearchController(searchResultsController: nil)
    var teachersInSearch = [Teacher]()


    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        server()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Пошук викладачів"
        self.navigationItem.searchController = search
        definesPresentationContext = true
        
        activityIndicator.startAnimating()
        tableView.isHidden = true
        self.view.bringSubviewToFront(activityIndicator)
        
        teachers = (isChoosenMyTeachers) ? myTeachers : allTeachers
        self.tableView.reloadData()
    }
    
    
    @IBAction func weekChanged(_ sender: UISegmentedControl) {
        didChangeSegment(segmentControl: segmentControl)
    }
    
    
    func didChangeSegment(segmentControl: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
            case 0:
                isChoosenMyTeachers = true
                self.teachers = []
                tableView.reloadData()
                teachers = myTeachers

                tableView.reloadData()
            case 1:
                self.allTeachers = self.allTeachers.sorted{Int($0.teacherID) ?? 0 < Int($1.teacherID) ?? 0}
                isChoosenMyTeachers = false
                self.teachers = []
                tableView.reloadData()

                teachers = allTeachers

                tableView.reloadData()
            default:
                break
        }
    }
    
    
    func server() {
        let stringURL = "https://api.rozklad.org.ua/v2/groups/\(Settings.shared.groupID)/teachers"
        guard let url = URL(string: stringURL) else { return }

        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()

            do {
                guard let serverFULLDATA = try? decoder.decode(WelcomeTeachers.self, from: data) else { return }
                let datum = serverFULLDATA.data
                self.myTeachers = datum
                self.teachers = self.myTeachers
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                    
                }
            }
        }
        task.resume()
        
        
        for i in 0..<55 {
            let offset = i * 100
            let stringURL = "https://api.rozklad.org.ua/v2/teachers?filter=%7B'limit':100,'offset':\(String(offset))%7D"
            
            let url = URL(string: stringURL)!
           
            
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()

                do {
                    guard let serverFULLDATA = try? decoder.decode(WelcomeTeachers.self, from: data) else { return }
                    let datum = serverFULLDATA.data
                    self.allTeachers += datum
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        
                        self.tableView.isHidden = false
                        self.tableView.reloadData()
                    }
                }
            }
            task.resume()
        }
    }

}

extension TeachersViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return teachersInSearch.count
        } else {
            return teachers.count
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: reuseID)
        
        if isSearching {
            cell.textLabel?.text = teachersInSearch[indexPath.row].teacherName
        } else {
            cell.textLabel?.text = teachers[indexPath.row].teacherName
        }
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showTeacherShedule2" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let destination = segue.destination as? TeacherSheduleViewController {
                    if isSearching {
                        destination.teacherID = teachersInSearch[indexPath.row].teacherID
                    } else {
                        destination.teacherID = teachers[indexPath.row].teacherID
                    }
                }
            }
        }
        
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard (storyboard?.instantiateViewController(withIdentifier: "TeacherSheduleViewController") as? TeacherSheduleViewController) != nil else { return }
        performSegue(withIdentifier: "showTeacherShedule2", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
}


//Mark: - extencions for search
extension TeachersViewController: UISearchResultsUpdating{

    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text else {
            return
        }
                
        if searchText == "" {
            isSearching = false
            teachersInSearch = []

            tableView.reloadData()
        } else {
            
            segmentControl.selectedSegmentIndex = 1
            didChangeSegment(segmentControl: segmentControl)
            
            isSearching = true
            teachersInSearch = []
            for teacher in teachers {
                if teacher.teacherFullName.lowercased().contains(searchText.lowercased()){
                    teachersInSearch.append(teacher)
                }
            }
            tableView.reloadData()
        }
    }
    
}
