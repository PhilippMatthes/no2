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
import MapKit
import Dropper


class TableViewController: UITableViewController {
    
    var stations = [Station]()
    var cells = [Int: StationCell]()
    var selectedStation: Station?
    var selector = IndexPath()
    var currentTimeSpan: String = Constants.timeList.first!
    var banner = Banner()
    var annotation: PollutionAnnotation?
    var indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initNavBar(withColor color: UIColor) {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        refreshControl.backgroundColor = color
        self.refreshControl = refreshControl
        
        let navigationItem = UINavigationItem(title: "")
        
        let refreshItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector (self.refreshButtonPressed (_:)))
        refreshItem.tintColor = UIColor.white
        
        let activityItem = UIBarButtonItem(customView: indicator)
        
        let timeSpanButton: UIButton = UIButton(type: UIButtonType.custom) as UIButton
        timeSpanButton.addTarget(self, action: #selector (self.timeSpanButtonPressed (_:)), for: UIControlEvents.touchUpInside)
        timeSpanButton.setTitle(currentTimeSpan, for: [.normal])
        timeSpanButton.setTitleColor(UIColor.white, for: [.normal])
        timeSpanButton.sizeToFit()
        let timeSpanItem: UIBarButtonItem = UIBarButtonItem(customView: timeSpanButton)
        
        
        navigationItem.leftBarButtonItems = [timeSpanItem,refreshItem,activityItem]
        
        
        let unitButton:UIButton = UIButton(type: UIButtonType.custom) as UIButton
        unitButton.addTarget(self, action: #selector (self.changeTypeButtonPressed (_:)), for: UIControlEvents.touchUpInside)
        unitButton.setTitle(State.shared.currentType.capitalized, for: [.normal])
        unitButton.setTitleColor(UIColor.white, for: [.normal])
        unitButton.sizeToFit()
        let unitBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: unitButton)
        navigationItem.rightBarButtonItem  = unitBarButtonItem
        
        
        navigationBar.setItems([navigationItem], animated: true)
        
        navigationBar.barTintColor = color
        navigationBar.isTranslucent = false
        navigationBar.barStyle = .black
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
    }
    
    @objc func refresh(refreshControl: UIRefreshControl) {
        updateCells {}
    }
    
    @objc func refreshButtonPressed(_ sender:UITapGestureRecognizer){
        updateCells {}
    }
    
    @objc func timeSpanButtonPressed(_ sender:UITapGestureRecognizer){
        let index = (Constants.timeList.index(of: currentTimeSpan)! + 1) % Constants.timeList.count
        currentTimeSpan = Constants.timeList[index]
        updateNavBar()
        updateCells {}
    }
    
    @objc func changeTypeButtonPressed(_ sender:UITapGestureRecognizer){
        let index = (Constants.units.index(of: State.shared.currentType)! + 1) % Constants.units.count
        State.shared.currentType = Constants.units[index]
        updateNavBar()
        changeUIColor(toColor: State.shared.currentColor)
    }
    
    func updateNavBar() {
        
        let navigationItem = UINavigationItem(title: "")
        
        let refreshItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector (self.refreshButtonPressed (_:)))
        refreshItem.tintColor = UIColor.white
        
        let activityItem = UIBarButtonItem(customView: indicator)
        
        let timeSpanButton: UIButton = UIButton(type: UIButtonType.custom) as UIButton
        timeSpanButton.addTarget(self, action: #selector (self.timeSpanButtonPressed (_:)), for: UIControlEvents.touchUpInside)
        timeSpanButton.setTitle(currentTimeSpan, for: [.normal])
        timeSpanButton.setTitleColor(UIColor.white, for: [.normal])
        timeSpanButton.sizeToFit()
        let timeSpanItem: UIBarButtonItem = UIBarButtonItem(customView: timeSpanButton)
        
        
        navigationItem.leftBarButtonItems = [timeSpanItem, refreshItem, activityItem]
        
        let unitButton:UIButton = UIButton(type: UIButtonType.custom) as UIButton
        unitButton.addTarget(self, action: #selector (self.changeTypeButtonPressed (_:)), for: UIControlEvents.touchUpInside)
        unitButton.setTitle(State.shared.currentType.capitalized, for: [.normal])
        unitButton.setTitleColor(UIColor.white, for: [.normal])
        unitButton.sizeToFit()
        let unitBarButtonItem:UIBarButtonItem = UIBarButtonItem(customView: unitButton)
        navigationItem.rightBarButtonItem  = unitBarButtonItem
        
        navigationBar.setItems([navigationItem], animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initUI(withColor: State.shared.currentColor)
        initNavBar(withColor: State.shared.currentColor)
        
        NSKeyedUnarchiver.setClass(Station.self, forClassName: "Station")
        if let loadedStations = DiskJockey.loadObject(ofType: [Station](), withIdentifier: "stations") {
            self.stations = loadedStations
        }
        if stations.isEmpty {
            banner.dismiss()
            banner = Banner(title: "Information", subtitle: NSLocalizedString("cellInformation", comment: ""), image: nil, backgroundColor: State.shared.currentColor)
            banner.dismissesOnTap = false
            banner.titleLabel.textColor = UIColor.white
            banner.position = BannerPosition.top
            banner.show()
            tableView.separatorStyle = .none
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateCells {}
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        banner.dismiss()
    }
    
    func initUI(withColor color: UIColor) {
        tableView.separatorStyle = .singleLineEtched
        tableView.separatorColor = color
        tableView.backgroundColor = color
    }
    
    func changeUIColor(toColor color: UIColor) {
        tableView.separatorColor = color
        updateCells {}
        tableView.backgroundColor = color
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        refreshControl.backgroundColor = color
        self.refreshControl = refreshControl
        navigationBar.animate(toBarTintColor: State.shared.currentColor, withDuration: 0.5)
        tabBarController!.tabBar.animate(toBarTintColor: State.shared.currentColor, withDuration: 0.5)
    }
    
    func updateCells(completionHandler: @escaping () -> ()) {
        indicator.startAnimating() 
        let timeSpanInDays = Constants.timeSpaces[currentTimeSpan]
        for entry in cells {
            let cell = entry.value
            let intraday = currentTimeSpan == NSLocalizedString("1 Day", comment: "1 Day")
            cell.getDataIfNecessary(withTimeSpanInDays: timeSpanInDays!, intraday: intraday) {
                var allReady = true
                for cell in self.cells {
                    if cell.value.isLoading {
                        allReady = false
                    }
                }
                if allReady {
                    self.indicator.stopAnimating()
                    self.refreshControl?.endRefreshing()
                }
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
                completionHandler()
            }
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 150
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath) as? StationCell {
            cells[indexPath.row] = cell
            
            let station = stations[indexPath.row]
            let coordinateLocation = CLLocation(latitude: station.entries.first!.latitude!,
                                                longitude: station.entries.first!.longitude!)
            CoordinateWizard.fetchCountryAndCity(location: coordinateLocation) { country, city in
                cell.stationLabel.text = "\(station.name!) - \(city) (\(country))"
            }
            cell.station = station
            return cell
        } else {
            print("Failed to dequeue reusable cell of type StationCell")
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            stations.remove(at: indexPath.row)
            NSKeyedArchiver.setClassName("Station", for: Station.self)
            DiskJockey.save(object: stations, withIdentifier: "stations")
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStation = stations[indexPath.row]
        if let entry = selectedStation!.entries.first {
            State.shared.transferAnnotation = entry.generateMapAnnotation()
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showDetail", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let vc = segue.destination as! DetailController
            vc.previousViewController = self
        }
    }
}

