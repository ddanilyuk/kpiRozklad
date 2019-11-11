//
//  TeacherDetailViewController.swift
//  kpiRozklad
//
//  Created by Denis on 26.10.2019.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit

class TeacherChoosingViewController: UIViewController {
    
    var chooserMyTeacher: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func didPressMyTeachers(_ sender: UIButton) {
        chooserMyTeacher = true
        
        performSegue(withIdentifier: "showTeachersVC", sender: self)

    }
    
    @IBAction func didPressAllTeachers(_ sender: Any) {
        chooserMyTeacher = false

        performSegue(withIdentifier: "showTeachersVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let destination = segue.destination as? TeachersViewController {
            destination.isChoosenMyTeachers = chooserMyTeacher
        }
        
    }
    
}
