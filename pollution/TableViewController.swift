//
//  TableController.swift
//  pollution
//
//  Created by Philipp Matthes on 07.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UITableViewController {
    
    var stations = [Station]()
    var selectedStation: Station?
    var selector = IndexPath()
    
    var annotation: PollutionAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .singleLineEtched
        tableView.separatorColor = UIColor.white
        
        if let loadedStations = DiskJockey.getStations() {
            self.stations = loadedStations
        }
        
    }
    
    @IBAction func userDidSwipeRight(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "showDetailView", sender: self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func doneButtonPressed(_ sender:UITapGestureRecognizer) {
        performSegueToReturnBack()
    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "StationCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StationCell else {
            fatalError("The dequeued cell is not an instance of StationCell.")
        }
        let station = stations[indexPath.row]
        cell.stationLabel.text = station.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            stations.remove(at: indexPath.row)
            DiskJockey.setStations(to: stations)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStation = stations[indexPath.row]
        DatabaseCaller.makeNotificationRequest(forLocation: self.selectedStation!.name!, withLimit: 1) {
            entries in
            if let entry = entries.first {
                self.annotation = DatabaseCaller.generateMapAnnotation(entry: entry)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showDetail", sender: self)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let vc = segue.destination as! DetailController
            vc.annotationThatWasClicked = self.annotation
        }
    }
}

