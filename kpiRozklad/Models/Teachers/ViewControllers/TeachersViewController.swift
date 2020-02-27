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
    var groupTeachers = [Teacher]()
    var allTeachers = [Teacher]()
    
    
    var isSearching = false
    let search = UISearchController(searchResultsController: nil)
    var teachersInSearch = [Teacher]()


    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActivityIndicator()

        serverGetAllTeachers()
        
        setupSegmentControl()
        
        setupNavigationAndSearch()
        
        setupTableView()
        
        if global.sheduleType == .groups {
            serverGroupTeachers()
        }
        
    }
    
    private func setupSegmentControl() {
        if global.sheduleType == .teachers {
            segmentControl.selectedSegmentIndex = 1
            didSegmentControlChangeState(segmentControl)
            segmentControl.isHidden = true
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicator.startAnimating()
        tableView.isHidden = true
        activityIndicator.isHidden = false
        self.view.bringSubviewToFront(activityIndicator)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigationAndSearch() {
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Пошук викладачів"
        self.navigationItem.searchController = search
        definesPresentationContext = true
    }
    
    @IBAction func didSegmentControlChangeState(_ sender: UISegmentedControl) {
        switch segmentControl.selectedSegmentIndex {
            case 0:
                self.teachers = []
                tableView.reloadData()
                
                teachers = groupTeachers

                tableView.reloadData()
            case 1:
                self.allTeachers = self.allTeachers.sorted{Int($0.teacherID) ?? 0 < Int($1.teacherID) ?? 0}
                self.teachers = []
                tableView.reloadData()

                teachers = allTeachers

                tableView.reloadData()
            default:
                break
        }
    }
    
    func serverGroupTeachers() {
        let stringURL = "https://api.rozklad.org.ua/v2/groups/\(Settings.shared.groupID)/teachers"
        guard let url = URL(string: stringURL) else { return }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()

            do {
                guard let serverFULLDATA = try? decoder.decode(WelcomeTeachers.self, from: data) else { return }
                self.groupTeachers = serverFULLDATA.data
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.tableView.isHidden = false
                    
                    self.teachers = self.groupTeachers
                    self.tableView.reloadData()

                }
            }
        }
        task.resume()
    }
    
    func serverGetAllTeachers() {
        let stringURL = "https://api.rozklad.org.ua/v2/teachers/?filter=%7B'showAll':true%7D"
        guard let url = URL(string: stringURL) else { return }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
        guard let data = data else { return }
        let decoder = JSONDecoder()
            do {
                guard let serverFULLDATA = try? decoder.decode(WelcomeTeachers.self, from: data) else { return }
                self.allTeachers = serverFULLDATA.data
                 
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.tableView.isHidden = false
                    
                    if global.sheduleType == .teachers {
                        self.teachers = self.allTeachers
                        self.tableView.reloadData()
                    }
                 }
             }
         }
         task.resume()
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
        if segue.identifier == "showTeacherSheduleFromAllTeachers" {
            if let indexPath = tableView.indexPathForSelectedRow {
                if let destination = segue.destination as? TeacherSheduleViewController {
                    if isSearching {
                        destination.teacher = teachersInSearch[indexPath.row]
                    } else {
                        destination.teacher = teachers[indexPath.row]
                    }
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard (storyboard?.instantiateViewController(withIdentifier: "TeacherSheduleViewController") as? TeacherSheduleViewController) != nil else { return }
        performSegue(withIdentifier: "showTeacherSheduleFromAllTeachers", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//Mark: - extencions for search
extension TeachersViewController: UISearchResultsUpdating{

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
                
        if searchText == "" {
            isSearching = false
            teachersInSearch = []

            tableView.reloadData()
        } else {
            isSearching = true
            teachersInSearch = []
            
            /// If search is taped change segmentControll to all teachers
            if global.sheduleType == .groups {
                segmentControl.selectedSegmentIndex = 1
                didSegmentControlChangeState(segmentControl)
            }

            for teacher in teachers {
                if teacher.teacherFullName.lowercased().contains(searchText.lowercased()){
                    teachersInSearch.append(teacher)
                }
            }
            tableView.reloadData()
        }
    }
    
}
