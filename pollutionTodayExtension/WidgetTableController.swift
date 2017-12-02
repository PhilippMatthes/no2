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

enum cellHeight : Int {
    case expanded = 150
    case compact = 85
}

class WidgetTableController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    
    var currentTimeSpan: String = Constants.timeList.first!
    var cells = [Int: StationCell]()
    
    var stations = [Station]()
    
    var timer: Timer?
    
    var index = 0
    
    var currentCellHeight: cellHeight = .expanded
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        State.shared.load()
        
        initUI(withColor: State.shared.currentColor)
        
        unitButton.setTitle(State.shared.currentType.uppercased(), for: .normal)
        
        NSKeyedUnarchiver.setClass(Station.self, forClassName: "Station")
        State.shared.defaults.synchronize()
        if let decoded = State.shared.defaults.object(forKey: "stations") as? NSData {
            if let loadedStations = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as? [Station] {
                self.stations = loadedStations
            }
        }
        
        if self.stations.count * currentCellHeight.rawValue > Int(view.frame.height) {
            timer = Timer.scheduledTimer(timeInterval: 6.0, target: self, selector: #selector(scroll), userInfo: nil, repeats: true)
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
        progressView.progressTintColor = color
        progressView.backgroundColor = UIColor.clear
        progressView.trackTintColor = UIColor.clear
        tableView.separatorStyle = .singleLineEtched
        tableView.separatorColor = color
    }
    
    @available(iOS 10.0, *)
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: maxSize.width, height:CGFloat(cellHeight.expanded.rawValue*stations.count))
            self.currentCellHeight = .expanded
            self.tableView.reloadData()
        } else if activeDisplayMode == .compact{
            self.preferredContentSize = CGSize(width: maxSize.width, height:CGFloat(cellHeight.compact.rawValue))
            self.currentCellHeight = .compact
            self.tableView.reloadData()
        }
    }
    
    @available(iOS, obsoleted: 10.0)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(currentCellHeight.rawValue)
    }
    
    @objc func scroll() {
        UIView.animate(withDuration: 5, animations: { () -> Void in
            self.progressView.setProgress(1.0, animated: true)
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.progressView.setProgress(0.0, animated: true)
            self.index += 1
            let currentRow = (self.index + 1) % (self.stations.count - 1)
            let indexPath = NSIndexPath(row: currentRow, section: 0)
            self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func updateCells(completionHandler: @escaping () -> ()) {
        let timeSpanInDays = Constants.timeSpaces[currentTimeSpan]
        var delay = 0.0
        
        self.indicator.startAnimating()
        
        for station in stations {
            let intraday = currentTimeSpan == NSLocalizedString("1 Day", comment: "1 Day")
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                station.getDataIfNecessary(withTimeSpanInDays: timeSpanInDays!, intraday: intraday) {
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
                    }
                    var allReady = true
                    for station in self.stations {
                        if !station.isReady {
                            allReady = false
                        }
                    }
                    if allReady {
                        DispatchQueue.main.async {
                            self.indicator.stopAnimating()
                        }
                    }
                    completionHandler()
                }
            })
            delay += 0.0
        }
        
    }
    
    
    @IBAction func timeButtonPressed(_ sender: UIButton) {
        let index = (Constants.timeList.index(of: currentTimeSpan)! + 1) % Constants.timeList.count
        currentTimeSpan = Constants.timeList[index]
        timeButton.setTitle(currentTimeSpan, for: [.normal])
        updateCells {}
    }
    
    @IBAction func unitButtonPressed(_ sender: UIButton) {
        let index = (Constants.units.index(of: State.shared.currentType)! + 1) % Constants.units.count
        State.shared.currentType = Constants.units[index]
        initUI(withColor: State.shared.currentColor)
        unitButton.setTitle(State.shared.currentType.uppercased(), for: [.normal])
        updateCells {}
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath) as? StationCell {
            cells[indexPath.row] = cell
            let station = stations[indexPath.row]
            if let city = station.city, let country = station.country {
                cell.stationLabel.text = "\(station.name!) - \(city) (\(country))"
            } else {
                cell.stationLabel.text = "\(station.name!)"
            }
            cell.station = station
            cell.emissionChart.setUpChart(intraday: true, entries: cell.station!.entries, type: .colorOnWhite)
            return cell
        } else {
            fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
