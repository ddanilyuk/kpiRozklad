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
    
    
    var isSearching = false
    let search = UISearchController(searchResultsController: nil)
    var teachersInSearch = [Teacher]()


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        server()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Поиск преподавателей"
        self.navigationItem.searchController = search
        definesPresentationContext = true
    }
    
    
    func server() {
        for i in 0..<51 {
            let offset = i * 100
            
            let stringURL = "https://api.rozklad.org.ua/v2/teachers?filter=%7B'limit':100,'offset':\(String(offset))%7D"

            let url = URL(string: stringURL)!
           
            
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let data = data else { return }
                let decoder = JSONDecoder()

                do {
                    guard let serverFULLDATA = try? decoder.decode(WelcomeTeachers.self, from: data) else { return }
                    let datum = serverFULLDATA.data
                    self.teachers += datum
                    print(self.teachers.count)
                    
                    DispatchQueue.main.async {
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
//            cell.detailTextLabel?.text = teachersInSearch[indexPath.row].teacherID
        } else {
            cell.textLabel?.text = teachers[indexPath.row].teacherName
//            cell.detailTextLabel?.text = teachers[indexPath.row].teacherID
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
            isSearching = true
            teachersInSearch = []
            for teacher in teachers {
                if teacher.teacherFullName.contains(searchText){
                    teachersInSearch.append(teacher)
                }
            }
            tableView.reloadData()
        }
    }
    
}
