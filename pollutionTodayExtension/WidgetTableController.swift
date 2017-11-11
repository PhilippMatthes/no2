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
import MapKit

class WidgetTableController: UITableViewController, NCWidgetProviding {
    
    var stations = [Station]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        State.shared.load()
        
        initUI(withColor: State.shared.currentColor)
        
        NSKeyedUnarchiver.setClass(Station.self, forClassName: "Station")
        State.shared.defaults.synchronize()
        if let decoded = State.shared.defaults.object(forKey: "stations") as? NSData {
            if let loadedStations = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as? [Station] {
                self.stations = loadedStations
            }
        }
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
        
        self.preferredContentSize = CGSize(width:self.view.frame.size.width, height:CGFloat(150*stations.count))
        
        if #available(iOS 10.0, *) {
            extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        } else {
            // Fallback on earlier versions
        }
    }
    
    func initUI(withColor color: UIColor) {
        tableView.separatorStyle = .singleLineEtched
        tableView.separatorColor = color
    }
    
    @available(iOS 10.0, *)
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: maxSize.width, height:CGFloat(150*stations.count))
        } else if activeDisplayMode == .compact{
            self.preferredContentSize = CGSize(width: maxSize.width, height: 150)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath) as? StationCell {
            let station = stations[indexPath.row]
            let coordinateLocation = CLLocation(latitude: station.entries.first!.latitude!,
                                                longitude: station.entries.first!.longitude!)
            CoordinateWizard.fetchCountryAndCity(location: coordinateLocation) { country, city in
                cell.stationLabel.text = "\(station.name!) - \(city) (\(country))"
            }
            cell.station = station
            cell.setUpChart(intraday: true)
            return cell
        } else {
            fatalError()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let station = stations[indexPath.row]
        let stationName = station.name!
        let stationNameEncoded = stationName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let myAppUrl = NSURL(string: "OpenApp://?stationName=\(stationNameEncoded)")!
        extensionContext?.open(myAppUrl as URL, completionHandler: { (success) in
            if (!success) {
                print("App launch failed!")
            }
        })
    }
    
}
