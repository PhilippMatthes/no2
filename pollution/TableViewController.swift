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
import BRYXBanner

class TableViewController: UITableViewController {
    
    var stations = [Station]()
    var selectedStation: Station?
    var selector = IndexPath()
    
    var banner = Banner()
    
    var annotation: PollutionAnnotation?
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .singleLineEtched
        
        let navigationItem = UINavigationItem(title: "")
        
        let refreshItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector (self.refreshButtonPressed (_:)))
        refreshItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = refreshItem
        
        let changeTypeItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.undo, target: self, action: #selector (self.changeTypeButtonPressed (_:)))
        changeTypeItem.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = changeTypeItem
        
        navigationBar.setItems([navigationItem], animated: true)
        
        navigationBar.barTintColor = Constants.colors[State.shared.currentType]!
        navigationBar.isTranslucent = false
        navigationBar.barStyle = .black
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
    }
    
    @objc func refreshButtonPressed(_ sender:UITapGestureRecognizer){
    }
    
    @objc func changeTypeButtonPressed(_ sender:UITapGestureRecognizer){
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initUI(withColor: Constants.colors[State.shared.currentType]!)
        if let loadedStations = DiskJockey.loadObject(ofType: [Station](), withIdentifier: "stations") {
            self.stations = loadedStations
        }
        if stations.isEmpty {
            banner.dismiss()
            banner = Banner(title: "Information", subtitle: NSLocalizedString("cellInformation", comment: ""), image: nil, backgroundColor: Constants.colors[State.shared.currentType]!)
            banner.dismissesOnTap = false
            banner.titleLabel.textColor = UIColor.white
            banner.position = BannerPosition.top
            banner.show()
            tableView.separatorStyle = .none
        }
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        banner.dismiss()
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
        return stations.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 150
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath) as? StationCell {
            let station = stations[indexPath.row]
            cell.stationLabel.text = station.name
            cell.station = station
            cell.setUpChart(intraday: true)
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
        selectedStation = stations[indexPath.row]
        if let entry = selectedStation!.entries.first {
            self.annotation = DatabaseCaller.generateMapAnnotation(entry: entry)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showDetail", sender: self)
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

