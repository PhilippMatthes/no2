//
//  TableController.swift
//  pollution
//
//  Created by Philipp Matthes on 07.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import SwiftSpinner

class TableViewController: UITableViewController {
    
    var stations = [Station]()
    var selectedStation: Station?
    var selector = IndexPath()
    
    var annotation: PollutionAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .singleLineEtched
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initUI(withColor: Constants.colors[State.shared.currentType]!)
        if let loadedStations = DiskJockey.loadObject(ofType: [Station](), withIdentifier: "stations") {
            self.stations = loadedStations
        }
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    func initUI(withColor color: UIColor) {
        tableView.separatorColor = color
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
        return stations.count + 1
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !(indexPath.row == 0)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 0 {
            return 130
        }
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell", for: indexPath) as? InformationCell {
                cell.informationLabel.text = NSLocalizedString("cellInformation", comment: "")
                return cell
            }
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath) as? StationCell {
            let station = stations[indexPath.row - 1]
            cell.stationLabel.text = station.name
            return cell
        } else {
            fatalError()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            stations.remove(at: indexPath.row)
            DiskJockey.save(object: stations, withIdentifier: "stations")
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        }
        selectedStation = stations[indexPath.row]
        SwiftSpinner.sharedInstance.innerColor = Constants.colors[State.shared.currentType]!
        SwiftSpinner.show(NSLocalizedString("loadingLocation", comment: "Loading\nlocation"), animated: true)
        DatabaseCaller.makeNotificationRequest(forLocation: self.selectedStation!.name!, withLimit: 1) {
            entries in
            if let entry = entries.first {
                self.annotation = DatabaseCaller.generateMapAnnotation(entry: entry)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showDetail", sender: self)
                }
            } else {
                DispatchQueue.main.async {
                    SwiftSpinner.show(NSLocalizedString("failedToLoad", comment: "Failed to load")).addTapHandler({
                        SwiftSpinner.hide()
                    }, subtitle: NSLocalizedString("tapToReturn", comment: "Tap to return."))
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let vc = segue.destination as! DetailController
            vc.annotationThatWasClicked = self.annotation
            vc.previousViewController = self
        }
    }
}

