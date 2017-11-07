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


class DetailController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
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
    var previousViewController: ViewController?
    var currentType: String?
    var showsIntradayInformation = true
    
    let dropper = Dropper(width: 100, height: 200)
    
    @IBOutlet weak var emissionChart: LineChartView!
    
    var measurements: [PollutionDataEntry]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels(withSource: annotationThatWasClicked!.entry!.measurements!.first!.source,
                     andLocation: annotationThatWasClicked!.entry!.location!)
        
        currentType = previousViewController!.currentType
        
        getData(fromDaysAgo: 0, intraday: showsIntradayInformation)
        
    }
    
    func getData(fromDaysAgo days: Int, intraday: Bool) {
        let date = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from:date as Date)
        DispatchQueue.global(qos: .default).async {
            self.measurements = DatabaseCaller.makeLocalRequest(forLocation: self.annotationThatWasClicked!.entry!.location!,                                                   withLimit: 10000, toDate:  dateString, fromDetailController: self, withPreviousController: self.previousViewController!)
            DispatchQueue.main.async {
                if !self.view.isHidden {
                    self.setUpChart(withType: self.currentType!, intraday: intraday)
                }
            }
        }
    }
    
    func updateLabels(withSource source: String?, andLocation location: String) {
        let coordinateLocation = CLLocation(latitude: annotationThatWasClicked!.coordinate.latitude,
                                  longitude: annotationThatWasClicked!.coordinate.longitude)
        CoordinateWizard.fetchCountryAndCity(location: coordinateLocation) { country, city in
            self.locationLabel.text = "\(NSLocalizedString("location", comment: "Location")): \(city) (\(country))"
        }
        if let source = source {
            self.sourceLabel.text = "\(NSLocalizedString("source", comment: "Source")): \(source)"
            self.stationLabel.text = "\(NSLocalizedString("station", comment: "Station")): \(location)"
        }
        else {
            self.sourceLabel.text = "\(NSLocalizedString("source", comment: "Source")): n/a"
            self.stationLabel.text = "\(NSLocalizedString("station", comment: "Station")): \(location)"
        }
        
    }
    
    func initDesign(withColor color: UIColor, andUnit unit: String) {
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
        
        let index = (Constants.units.index(of: currentType!)! + 1) % Constants.units.count
        currentType = Constants.units[index]
        changeColor(to: Constants.colors[currentType!]!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.updateChart(withType: self.currentType!, intraday: self.showsIntradayInformation)
        })
        
        unitLabelBackground.animateButtonPress(withBorderColor: Constants.colors[currentType!]!, width: 4.0, andDuration: 0.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.unitLabelBackground.animateButtonRelease(withBorderColor: Constants.colors[self.currentType!]!, width: 4.0, andDuration: 0.1)
        })
    }
    @objc func timeButtonClicked(sender:UITapGestureRecognizer) {
        
        if dropper.status == .hidden {
            dropper.showWithAnimation(0.15, options: .left, button: timeLabelButton)
        } else {
            dropper.hideWithAnimation(0.1)
        }
        
        
        timeLabelBackground.animateButtonPress(withBorderColor: Constants.colors[currentType!]!, width: 4.0, andDuration: 0.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.timeLabelBackground.animateButtonRelease(withBorderColor: Constants.colors[self.currentType!]!, width: 4.0, andDuration: 0.1)
        })
    }
    
    func changeColor(to color: UIColor) {
        dropper.cellColor = color
        dropper.tintColor = color
        dropper.refresh()
        
        unitLabel.text = currentType!.capitalized
        unitLabel.textColor = color
        timeLabel.textColor = color
        infoButton.animate(toBackgroundColor: color, withDuration: 2.0)
        
        SwiftSpinner.sharedInstance.innerColor = color
        let navigationItem = UINavigationItem(title: NSLocalizedString("detailViewTitle", comment: "Detail"))
        
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector (self.closeButtonPressed (_:)))
        doneItem.tintColor = color
        navigationItem.rightBarButtonItem = doneItem
        
        let receiveNotificationsItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.bookmarks, target: self, action: #selector (self.receiveNotificationsButtonPressed (_:)))
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
    
    @objc func receiveNotificationsButtonPressed(_ sender:UITapGestureRecognizer){
        let station = Station(name: annotationThatWasClicked!.entry!.location!,
                              latitude: annotationThatWasClicked!.coordinate.latitude,
                              longitude: annotationThatWasClicked!.coordinate.longitude)
        DiskJockey.extendStationsBy(station: station)
    }
    
    func performSegueToReturnBack()  {
        previousViewController!.currentType = currentType!
        previousViewController!.unitLabel.text = currentType!.capitalized
        previousViewController!.unitLabelBackground.layer.backgroundColor = Constants.colors[currentType!]?.cgColor
        previousViewController!.searchButtonBackground.layer.backgroundColor = Constants.colors[currentType!]?.cgColor
        previousViewController!.tabBarController!.tabBar.barTintColor = Constants.colors[currentType!]
        previousViewController!.updateAnnotations(withType: currentType!)
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func updateChart(withType type: String, intraday: Bool) {
        var backgroundLog = [Double]()
        var emissionLog = [Double]()
        var dateLog = [String]()
        
        for measurementList in measurements! {
            for measurement in measurementList.measurements! {
                if measurement.type == currentType! {
                    backgroundLog.append(Constants.maxValues[currentType!]!)
                    emissionLog.append(measurement.value!)
                    let cutOff = String(measurement.date!.dropFirst(11))
                    let time = String(cutOff.prefix(5))
                    let date = String(measurement.date!.prefix(10))
                    if intraday {
                        dateLog.append(time)
                    }
                    else {
                        let convertedDateString = DateTranslator.translateDate(fromDateFormat: "yyyy-MM-dd",
                                                                               toDateFormat: NSLocalizedString("shortDateFormat", comment: "Date format"),
                                                                               withDate: date)
                        dateLog.append(convertedDateString)
                    }
                }
            }
        }
        if emissionLog.count == 0 {
            return
        }
        
        emissionChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:dateLog)
        emissionChart.xAxis.setLabelCount(5, force: false)
        emissionChart.xAxis.labelRotationAngle = 0
        emissionChart.xAxis.labelTextColor = UIColor.white
        
        let maxValue = Double(emissionLog.max()!)
        
        var yAxisValues = [String]()
        for i in 0..<Int(max(Constants.maxValues[currentType!]!, maxValue)) {
            if i == Int(Constants.maxValues[currentType!]!) {
                yAxisValues.append(NSLocalizedString("high", comment: "High"))
            }
            else {
                yAxisValues.append("\(i) µg/m³")
            }
        }
        
        emissionChart.leftAxis.valueFormatter = IndexAxisValueFormatter(values:yAxisValues)
        emissionChart.leftAxis.setLabelCount(10, force: false)
        emissionChart.leftAxis.labelTextColor = UIColor.white
        emissionChart.leftAxis.axisMaximum = max(Constants.maxValues[currentType!]!, maxValue)
        
        var barChartEntries = [BarChartDataEntry]()
        var backgroundChartEntries = [BarChartDataEntry]()
        var barChartColors = [UIColor]()
        
        //        let maxSpeed = speedLog.max(by: {$0.1 < $1.1 })!.1
        
        for i in 0..<emissionLog.count {
            let emission = emissionLog[i]
            let value = BarChartDataEntry(x: Double(i), y: Double(emission))
            barChartEntries.insert(value, at: 0)
            
            var fraction = CGFloat(0.0)
            if maxValue != 0.0 {
                fraction = min(0.7,CGFloat(Double(emission)/maxValue))
            }
            let color = UIColor.white.withAlphaComponent(fraction)
            barChartColors.insert(color, at: 0)
        }
        
        for i in 0..<backgroundLog.count {
            let backgroundValue = backgroundLog[i]
            let value = BarChartDataEntry(x: Double(i), y: backgroundValue)
            backgroundChartEntries.insert(value, at: 0)
        }
        
        
        let emissionLine = BarChartDataSet(values: barChartEntries, label: nil)
        emissionLine.colors = barChartColors
        
        let backgroundLine = BarChartDataSet(values: backgroundChartEntries, label: nil)
        backgroundLine.colors = [UIColor.white.withAlphaComponent(0.2)]
        
        let data = BarChartData()
        
        data.addDataSet(emissionLine)
        data.addDataSet(backgroundLine)
        
        data.setDrawValues(false)
        
        emissionChart.animate(xAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCubic)
        
        emissionChart.data = data
        emissionChart.notifyDataSetChanged()
        
        emissionChart.noDataTextColor = UIColor.white
        emissionChart.noDataText = NSLocalizedString("noData", comment: "No Data available")
    }
    
    func setUpChart(withType type: String, intraday: Bool) {
        var backgroundLog = [Double]()
        var emissionLog = [Double]()
        var dateLog = [String]()
        
        for measurementList in measurements! {
            for measurement in measurementList.measurements! {
                if measurement.type == currentType! {
                    backgroundLog.append(Constants.maxValues[currentType!]!)
                    emissionLog.append(measurement.value!)
                    let cutOff = String(measurement.date!.dropFirst(11))
                    let time = String(cutOff.prefix(5))
                    let date = String(measurement.date!.prefix(10))
                    if intraday {
                        dateLog.append(time)
                    }
                    else {
                        let convertedDateString = DateTranslator.translateDate(fromDateFormat: "yyyy-MM-dd",
                                                                               toDateFormat: NSLocalizedString("shortDateFormat", comment: "Date format"),
                                                                               withDate: date)
                        dateLog.append(convertedDateString)
                    }
                }
            }
        }
        if emissionLog.count == 0 {
            return
        }
        
        emissionChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:dateLog)
        emissionChart.xAxis.setLabelCount(5, force: false)
        emissionChart.xAxis.labelRotationAngle = 0
        emissionChart.xAxis.labelTextColor = UIColor.white
        
        let maxValue = Double(emissionLog.max()!)
        
        var yAxisValues = [String]()
        for i in 0..<Int(max(Constants.maxValues[currentType!]!, maxValue)) {
            if i == Int(Constants.maxValues[currentType!]!) {
                yAxisValues.append(NSLocalizedString("high", comment: "High"))
            }
            else {
                yAxisValues.append("\(i) µg/m³")
            }
        }
        
        emissionChart.leftAxis.valueFormatter = IndexAxisValueFormatter(values:yAxisValues)
        emissionChart.leftAxis.setLabelCount(10, force: false)
        emissionChart.leftAxis.labelTextColor = UIColor.white
        
        emissionChart.delegate = self
        emissionChart.chartDescription?.text = nil
        emissionChart.leftAxis.axisMinimum = 0
        emissionChart.rightAxis.enabled = false
        emissionChart.drawBordersEnabled = false
        emissionChart.legend.enabled = false
        emissionChart.leftAxis.drawGridLinesEnabled = true
        emissionChart.leftAxis.gridColor = UIColor.white
        emissionChart.leftAxis.labelTextColor = UIColor.white
        emissionChart.leftAxis.axisLineColor = UIColor.white
        emissionChart.isUserInteractionEnabled = false
        emissionChart.leftAxis.axisMaximum = max(Constants.maxValues[currentType!]!, maxValue)
        emissionChart.xAxis.drawGridLinesEnabled = false
        emissionChart.xAxis.drawAxisLineEnabled = false
        emissionChart.noDataTextColor = UIColor.white
        emissionChart.noDataText = NSLocalizedString("noData", comment: "No Data available")
        
        var barChartEntries = [BarChartDataEntry]()
        var backgroundChartEntries = [BarChartDataEntry]()
        var barChartColors = [UIColor]()
        
        //        let maxSpeed = speedLog.max(by: {$0.1 < $1.1 })!.1
        
        for i in 0..<emissionLog.count {
            let emission = emissionLog[i]
            let value = BarChartDataEntry(x: Double(i), y: Double(emission))
            barChartEntries.insert(value, at: 0)
            
            var fraction = CGFloat(0.0)
            if maxValue != 0.0 {
                fraction = min(0.7,CGFloat(Double(emission)/maxValue))
            }
            let color = UIColor.white.withAlphaComponent(fraction)
            barChartColors.insert(color, at: 0)
        }
        
        for i in 0..<backgroundLog.count {
            let backgroundValue = backgroundLog[i]
            let value = BarChartDataEntry(x: Double(i), y: backgroundValue)
            backgroundChartEntries.insert(value, at: 0)
        }
        
        
        let emissionLine = BarChartDataSet(values: barChartEntries, label: nil)
        emissionLine.colors = barChartColors
        
        let backgroundLine = BarChartDataSet(values: backgroundChartEntries, label: nil)
        backgroundLine.colors = [UIColor.white.withAlphaComponent(0.2)]
        
        let data = BarChartData()
        
        data.addDataSet(emissionLine)
        data.addDataSet(backgroundLine)
        
        data.setDrawValues(false)
        
        emissionChart.animate(xAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCubic)
        
        emissionChart.data = data
        emissionChart.notifyDataSetChanged()
    }
    
    @IBAction func infoButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "showUnitInformation", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUnitInformation" {
            let vc = segue.destination as! UnitInformationController
            vc.previousViewController = previousViewController!
            vc.initDesign(withColor: Constants.colors[currentType!]!, andUnit: currentType!)
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
        getData(fromDaysAgo: Constants.timeSpaces[contents]!, intraday: showsIntradayInformation)
        timeLabel.text = contents
    }
}
