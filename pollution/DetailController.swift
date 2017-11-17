//
//  DetailController.swift
//  pollution
//
//  Created by Philipp Matthes on 28.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import Charts
import SwiftSpinner
import UIKit
import Dropper
import MapKit
import BRYXBanner


enum GeoCoderLoadingState {
    case beforeLoading
    case afterLoading
}


class DetailController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var timeLabelButton: UIButton!
    @IBOutlet weak var timeLabelBackground: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var unitLabelBackground: UIProgressView!
    @IBOutlet var viewBackground: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var annotationThatWasClicked: PollutionAnnotation?
    var stationThatWasClicked: Station?
    var showsIntradayInformation = true
    
    var previousViewController: UIViewController?
    
    var banner = Banner()
    
    var dropper = Dropper(width: 100, height: 200)
    
    @IBOutlet weak var emissionChart: BarChartView!
    
    var measurements: [PollutionDataEntry]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = State.shared.currentColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.annotationThatWasClicked = State.shared.transferAnnotation!
        
        self.updateLabels(.beforeLoading)
        
        self.initDesign(withColor: State.shared.currentColor)
        
        self.getData(withTimeSpanInDays: 1, intraday: self.showsIntradayInformation) {
            let coordinateLocation = CLLocation(latitude: self.annotationThatWasClicked!.coordinate.latitude,
                                                longitude: self.annotationThatWasClicked!.coordinate.longitude)
            CoordinateWizard.fetchCountryAndCity(location: coordinateLocation) { country, city in
                self.stationThatWasClicked = Station(name: self.annotationThatWasClicked!.entry!.location!,
                                                     latitude: self.annotationThatWasClicked!.coordinate.latitude,
                                                     longitude: self.annotationThatWasClicked!.coordinate.longitude,
                                                     entries: self.measurements!,
                                                     city: city,
                                                     country: country)
                self.updateLabels(.afterLoading)
            }
        }
    }
    
    func getData(withTimeSpanInDays days: Int, intraday: Bool, completion: @escaping () -> ()) {
        
        let mostRecentMeasurement = annotationThatWasClicked?.entry?.getMostRecentMeasurement()
        let mostRecentDate = mostRecentMeasurement?.getConvertedDate()

        let toDate = Calendar.current.date(byAdding: .day, value: -days, to: mostRecentDate!)!
        
        DispatchQueue.global(qos: .default).async {
            DatabaseCaller.makeLocalRequest(forLocation: self.annotationThatWasClicked!.entry!.location!,                                                   withLimit: 10000, toDate:  toDate, fromDate: mostRecentDate!) {
                entries in
                self.measurements = entries
                DispatchQueue.main.async {
                    self.emissionChart.setUpChart(intraday: intraday, entries: self.measurements!, type: .whiteOnColor)
                    completion()
                }
            }
        }
    }
    
    func updateLabels(_ state: GeoCoderLoadingState) {
        switch state {
        case .afterLoading:
            if let station = stationThatWasClicked {
                if let city = station.city, let country = station.country {
                    self.stationLabel.text = "\(NSLocalizedString("station", comment: "Station")): \(station.name!)"
                    self.locationLabel.text = "\(city) - \(country)"
                } else {
                    self.stationLabel.text = "\(NSLocalizedString("station", comment: "Station")): \(station.name!)"
                    self.locationLabel.text = "\(NSLocalizedString("location", comment: "Location")): n/a"
                }
            } else {
                self.stationLabel.text = "\(NSLocalizedString("station", comment: "Station")): n/a"
                self.locationLabel.text = "\(NSLocalizedString("location", comment: "Location")): n/a"
            }
        case .beforeLoading:
            if let station = stationThatWasClicked {
                self.stationLabel.text = "\(NSLocalizedString("station", comment: "Station")): \(station.name!)"
                self.locationLabel.text = "\(NSLocalizedString("location", comment: "Location")): \(NSLocalizedString("loading", comment: "Loading..."))"
            } else {
                self.stationLabel.text = "\(NSLocalizedString("station", comment: "Station")): n/a"
                self.locationLabel.text = "\(NSLocalizedString("location", comment: "Location")): n/a"
            }
        }
    }
    
    func initDesign(withColor color: UIColor) {
        view.addSubview(navigationBar)
        let unitButtonRecognizer = UITapGestureRecognizer(target: self, action:  #selector (self.unitButtonClicked(sender:)))
        unitLabelBackground.addGestureRecognizer(unitButtonRecognizer)
        unitLabelBackground.layer.cornerRadius = Constants.cornerRadius
        unitLabelBackground.progressViewStyle = .bar
        unitLabelBackground.setProgress(0.0, animated: true)
        unitLabelBackground.progressTintColor = UIColor.white.withAlphaComponent(0.5)
        unitLabelBackground.clipsToBounds = true
        
        let timeButtonRecognizer = UITapGestureRecognizer(target: self, action:  #selector (self.timeButtonClicked(sender:)))
        timeLabelBackground.addGestureRecognizer(timeButtonRecognizer)
        timeLabelBackground.layer.cornerRadius = Constants.cornerRadius
        timeLabelBackground.progressViewStyle = .bar
        timeLabelBackground.setProgress(0.0, animated: true)
        timeLabelBackground.progressTintColor = UIColor.white.withAlphaComponent(0.5)
        timeLabelBackground.clipsToBounds = true
        
        infoButton.layer.cornerRadius = 12
        view.addSubview(unitLabelBackground)
        
        dropper.items = Constants.timeList
        dropper.cellBackgroundColor = UIColor.white
        dropper.cornerRadius = Constants.cornerRadius
        dropper.delegate = self

        changeColor(to: color)
    }
    
    @objc func unitButtonClicked(sender:UITapGestureRecognizer) {
        
        let index = (Constants.units.index(of: State.shared.currentType)! + 1) % Constants.units.count
        State.shared.currentType = Constants.units[index]
        changeColor(to: State.shared.currentColor)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.emissionChart.updateChart(intraday: self.showsIntradayInformation, entries: self.measurements!, type: .whiteOnColor)
        })
        
        unitLabelBackground.animateClick(withBorderColor: State.shared.currentColor, width: 4.0, andDuration: 0.2)
    }
    @objc func timeButtonClicked(sender:UITapGestureRecognizer) {
        
        if dropper.status == .hidden {
            dropper.showWithAnimation(0.15, options: .left, button: timeLabelButton)
        } else {
            dropper.hideWithAnimation(0.1)
        }
        
        timeLabelBackground.animateClick(withBorderColor: State.shared.currentColor, width: 4.0, andDuration: 0.2)
    }
    
    func changeColor(to color: UIColor) {
        dropper.cellColor = color
        dropper.tintColor = color
        dropper.refresh()
        
        unitLabel.text = State.shared.currentType.capitalized
        unitLabel.textColor = color
        timeLabel.textColor = color
        infoButton.animate(toBackgroundColor: color, withDuration: 2.0)
        
        SwiftSpinner.sharedInstance.innerColor = color
        let navigationItem = UINavigationItem(title: NSLocalizedString("detailViewTitle", comment: "Detail"))
        
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector (self.closeButtonPressed (_:)))
        doneItem.tintColor = color
        navigationItem.rightBarButtonItem = doneItem
        
        let receiveNotificationsItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector (self.receiveNotificationsButtonPressed (_:)))
        receiveNotificationsItem.tintColor = color
        navigationItem.leftBarButtonItem = receiveNotificationsItem
        
        navigationBar.setItems([navigationItem], animated: true)
        
        navigationBar.tintColor = color
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:color]
        
        viewBackground.animate(toBackgroundColor: color, withDuration: 2.0)
    }
    
    @IBAction func userSwipedDown(_ sender: UISwipeGestureRecognizer) {
//        performSegueToReturnBack()
    }
    
    @objc func closeButtonPressed(_ sender:UITapGestureRecognizer){
        performSegueToReturnBack()
    }
    
    @objc func receiveNotificationsButtonPressed(_ sender:UITapGestureRecognizer) {
        NSKeyedArchiver.setClassName("Station", for: Station.self)
        NSKeyedUnarchiver.setClass(Station.self, forClassName: "Station")
        DiskJockey.loadAndExtendList(withObject: stationThatWasClicked!, andIdentifier: "stations")
        banner.dismiss()
        banner = Banner(title: NSLocalizedString("stationSaved", comment: "Station saved"), subtitle: nil, image: nil, backgroundColor: UIColor.white)
        banner.dismissesOnTap = true
        banner.titleLabel.textColor = State.shared.currentColor
        banner.position = BannerPosition.top
        banner.show(duration: 2.0)
    }
    
    func performSegueToReturnBack()  {
        
        if let vc = previousViewController as? ViewController {
            vc.initUI()
            vc.updateAnnotations(withType: State.shared.currentType)
        }
        if let vc = previousViewController as? TableViewController {
            vc.initUI(withColor: State.shared.currentColor)
            vc.initNavBar(withColor: State.shared.currentColor)
            vc.tableView.reloadData()
        }
        
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    @IBAction func infoButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "showUnitInformation", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUnitInformation" {
            let vc = segue.destination as! UnitInformationController
            vc.initDesign(withColor: State.shared.currentColor, andUnit: State.shared.currentType)
        }
    }
    
}

extension DetailController: DropperDelegate {
    func DropperSelectedRow(_ path: IndexPath, contents: String) {
        if contents == NSLocalizedString("1 Day", comment: "1 Day") {
            showsIntradayInformation = true
        }
        else {
            showsIntradayInformation = false
        }
        getData(withTimeSpanInDays: Constants.timeSpaces[contents]!, intraday: showsIntradayInformation) {
            
        }
        timeLabel.text = contents
    }
}
