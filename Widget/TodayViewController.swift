//
//  TodayViewController.swift
//  Widget
//
//  Created by Денис Данилюк on 07.02.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        self.preferredContentSize = CGSize(width: self.view.frame.size.width, height: 350)

//        self.extensionContext.sv
        // Do any additional setup after loading the view.
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 350)
        }
    }
    
    private func setupTableView() {
            tableView.register(UINib(nibName: LessonTableViewCell.identifier, bundle: Bundle.main), forCellReuseIdentifier: LessonTableViewCell.identifier)
            tableView.delegate = self
            tableView.dataSource = self
    //        var insetsContentViewsToSafeArea: Bool = true
    //        tableView.insetsContentViewsToSafeArea = false

    }
}

extension TodayViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LessonTableViewCell.identifier, for: indexPath) as? LessonTableViewCell else { return UITableViewCell() }
        cell.lessonLabel.text = "ОТДЫХ"
        return cell
    }
    
    
}
