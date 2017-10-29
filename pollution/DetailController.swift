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

class DetailController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var unitLabelBackground: UIProgressView!
    @IBOutlet var viewBackground: UIView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var annotationThatWasClicked: PollutionAnnotation?
    var previousViewController: ViewController?
    var currentType: String?
    
    @IBOutlet weak var emissionChart: LineChartView!
    @IBOutlet weak var reflectionChart: LineChartView!
    
    var measurements: [PollutionDataEntry]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentType = previousViewController!.currentType
        
        let date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from:date as Date)
        DispatchQueue.global(qos: .default).async {
            self.measurements = DatabaseCaller.makeLocalRequest(forLocation: self.annotationThatWasClicked!.entry!.location!,                                                   withLimit: 100, toDate:  dateString, fromDetailController: self, withPreviousController: self.previousViewController!)
            DispatchQueue.main.async {
                if !self.view.isHidden {
                    self.setUpChart(withType: self.currentType!)
                }
            }
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
        infoButton.layer.cornerRadius = 12
        view.addSubview(unitLabelBackground)
        changeColor(to: color)
    }
    
    @objc func unitButtonClicked(sender:UITapGestureRecognizer) {
        
        let index = (Constants.units.index(of: currentType!)! + 1) % Constants.units.count
        currentType = Constants.units[index]
        changeColor(to: Constants.colors[currentType!]!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.updateChart(withType: self.currentType!)
        })
        
        
        unitLabelBackground.animateButtonPress(withBorderColor: Constants.colors[currentType!]!, width: 4.0, andDuration: 0.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.unitLabelBackground.animateButtonRelease(withBorderColor: Constants.colors[self.currentType!]!, width: 4.0, andDuration: 0.1)
        })
    }
    
    func changeColor(to color: UIColor) {
        unitLabel.text = currentType!.capitalized
        unitLabel.textColor = Constants.colors[currentType!]
        infoButton.layer.backgroundColor = Constants.colors[currentType!]?.cgColor
        
        SwiftSpinner.sharedInstance.innerColor = color
        let navigationItem = UINavigationItem(title: "Detail")
        
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector (self.closeButtonPressed (_:)))
        doneItem.tintColor = color
        navigationItem.rightBarButtonItem = doneItem
        navigationBar.setItems([navigationItem], animated: true)
        
        navigationBar.tintColor = color
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:color]
        
        viewBackground.backgroundColor = color
    }
    
    @IBAction func userSwipedDown(_ sender: UISwipeGestureRecognizer) {
        performSegueToReturnBack()
    }
    
    @objc func closeButtonPressed(_ sender:UITapGestureRecognizer){
        performSegueToReturnBack()
    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func updateChart(withType type: String) {
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
                    if time == "00:00:00" {
                        dateLog.append(date)
                    }
                    else {
                        dateLog.append(time)
                    }
                }
            }
        }
        if emissionLog.count == 0 {
            return
        }
        
        emissionChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:dateLog)
        emissionChart.xAxis.setLabelCount(dateLog.count/4, force: false)
        emissionChart.xAxis.labelRotationAngle = 45
        emissionChart.xAxis.labelTextColor = UIColor.white
        
        let maxValue = Double(emissionLog.max()!)
        
        var yAxisValues = [String]()
        for i in 0..<Int(max(Constants.maxValues[currentType!]!, maxValue)) {
            if i == Int(Constants.maxValues[currentType!]!) {
                yAxisValues.append("High")
            }
            else {
                yAxisValues.append("\(i) µg/m³")
            }
        }
        
        emissionChart.leftAxis.valueFormatter = IndexAxisValueFormatter(values:yAxisValues)
        emissionChart.leftAxis.setLabelCount(dateLog.count/5, force: false)
        emissionChart.leftAxis.labelTextColor = UIColor.white
        emissionChart.leftAxis.axisMaximum = max(Constants.maxValues[currentType!]!, maxValue)
        
        reflectionChart.leftAxis.valueFormatter = IndexAxisValueFormatter(values:yAxisValues)
        reflectionChart.leftAxis.setLabelCount(dateLog.count/5, force: false)
        reflectionChart.leftAxis.labelTextColor = UIColor.white
        reflectionChart.leftAxis.axisMaximum = max(Constants.maxValues[currentType!]!, maxValue)
        
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
                fraction = CGFloat(Double(emission)/maxValue)
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
        reflectionChart.animate(xAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCubic)
        
        emissionChart.data = data
        reflectionChart.data = data
        emissionChart.notifyDataSetChanged()
        reflectionChart.notifyDataSetChanged()
    }
    
    func setUpChart(withType type: String) {
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
                    if time == "00:00:00" {
                        dateLog.append(date)
                    }
                    else {
                        dateLog.append(time)
                    }
                }
            }
        }
        if emissionLog.count == 0 {
            return
        }
        
        emissionChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:dateLog)
        emissionChart.xAxis.setLabelCount(dateLog.count/4, force: false)
        emissionChart.xAxis.labelRotationAngle = 45
        emissionChart.xAxis.labelTextColor = UIColor.white
        
        let maxValue = Double(emissionLog.max()!)
        
        var yAxisValues = [String]()
        for i in 0..<Int(max(Constants.maxValues[currentType!]!, maxValue)) {
            if i == Int(Constants.maxValues[currentType!]!) {
                yAxisValues.append("High")
            }
            else {
                yAxisValues.append("\(i) µg/m³")
            }
        }
        
        emissionChart.leftAxis.valueFormatter = IndexAxisValueFormatter(values:yAxisValues)
        emissionChart.leftAxis.setLabelCount(dateLog.count/5, force: false)
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
        
        reflectionChart.leftAxis.valueFormatter = IndexAxisValueFormatter(values:yAxisValues)
        reflectionChart.leftAxis.setLabelCount(dateLog.count/5, force: false)
        reflectionChart.leftAxis.labelTextColor = UIColor.white
        
        reflectionChart.delegate = self
        reflectionChart.alpha = 0.2
        reflectionChart.layer.transform = CATransform3DMakeRotation(CGFloat(Double.pi), 1.0, 0.0, 0.0)
        reflectionChart.chartDescription?.text = nil
        reflectionChart.leftAxis.axisMinimum = 0
        reflectionChart.rightAxis.enabled = false
        reflectionChart.leftAxis.drawGridLinesEnabled = true
        reflectionChart.leftAxis.gridColor = UIColor.white
        reflectionChart.leftAxis.labelTextColor = UIColor.white
        reflectionChart.leftAxis.axisLineColor = UIColor.white
        reflectionChart.xAxis.enabled = false
        reflectionChart.drawBordersEnabled = false
        reflectionChart.legend.enabled = false
        reflectionChart.isUserInteractionEnabled = false
        reflectionChart.leftAxis.axisMaximum = max(Constants.maxValues[currentType!]!, maxValue)
        reflectionChart.xAxis.drawGridLinesEnabled = false
        reflectionChart.xAxis.drawAxisLineEnabled = false
        
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
                fraction = CGFloat(Double(emission)/maxValue)
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
        reflectionChart.animate(xAxisDuration: 2.0, easingOption: ChartEasingOption.easeInOutCubic)
        
        emissionChart.data = data
        reflectionChart.data = data
        emissionChart.notifyDataSetChanged()
        reflectionChart.notifyDataSetChanged()
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

