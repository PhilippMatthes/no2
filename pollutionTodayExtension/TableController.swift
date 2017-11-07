//
//  TableController.swift
//  DragTimer
//
//  Created by Philipp Matthes on 06.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import NotificationCenter

class TableController: UITableViewController, NCWidgetProviding {
    
    var entries = [PollutionDataEntry]()
    var cells = [MeasurementCell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        self.preferredContentSize = CGSize(width:self.view.frame.size.width, height:CGFloat(50*entries.count))
        
        if #available(iOS 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        } else {
            // Fallback on earlier versions
        }
    }
    
    func loadData() {
        
    }
    
    @available(iOS 10.0, *)
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: maxSize.width, height:CGFloat(50*entries.count))
        } else if activeDisplayMode == .compact{
            self.preferredContentSize = CGSize(width: maxSize.width, height: 50)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MeasurementCell", for: indexPath) as? MeasurementCell else {
            fatalError("The dequeued cell is not an instance of MeasurementCell.")
        }
        cell.setEntry(entry: entries[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}
