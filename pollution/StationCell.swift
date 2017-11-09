//
//  StationCell.swift
//  pollution
//
//  Created by Philipp Matthes on 07.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit
import Charts


class StationCell: UITableViewCell, ChartViewDelegate {
    
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var emissionChart: BarChartView!
    
    var station: Station?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = false
        self.isHidden = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUpChart(intraday: Bool) {
        
        emissionChart.delegate = self
        emissionChart.chartDescription?.text = nil
        emissionChart.leftAxis.axisMinimum = 0
        emissionChart.rightAxis.enabled = false
        emissionChart.drawBordersEnabled = false
        emissionChart.legend.enabled = false
        emissionChart.leftAxis.enabled = true
        emissionChart.leftAxis.drawGridLinesEnabled = true
        emissionChart.leftAxis.gridColor = UIColor.white
        emissionChart.leftAxis.labelTextColor = UIColor.white
        emissionChart.leftAxis.axisLineColor = UIColor.white
        emissionChart.rightAxis.enabled = false
        emissionChart.isUserInteractionEnabled = false
        emissionChart.xAxis.drawGridLinesEnabled = false
        emissionChart.xAxis.drawAxisLineEnabled = false
        emissionChart.noDataTextColor = UIColor.black
        emissionChart.noDataText = NSLocalizedString("noData", comment: "No Data available")
        
        var backgroundLog = [Double]()
        var emissionLog = [Double]()
        var dateLog = [String]()
        for measurementList in station!.entries {
            for measurement in measurementList.measurements {
                if measurement.type == State.shared.currentType {
                    backgroundLog.append(Constants.maxValues[State.shared.currentType]!)
                    emissionLog.append(measurement.value!)
                    
                    let localTime = measurement.getLocalTimeString()
                
                    let date = String(measurement.date!.prefix(10))
                    let convertedDateString = DateTranslator.translateDate(fromDateFormat: "yyyy-MM-dd",
                                                                           toDateFormat: NSLocalizedString("shortDateFormat", comment: "Date format"),
                                                                           withDate: date)
                    
                    if intraday {
                        dateLog.append("\(convertedDateString) \(localTime)")
                    }
                    else {
                        
                        dateLog.append(convertedDateString)
                    }
                }
            }
        }
        if emissionLog.count == 0 {
            emissionChart.data = nil
            emissionChart.notifyDataSetChanged()
            return
        }
        
        emissionChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:dateLog)
        emissionChart.xAxis.setLabelCount(3, force: false)
        emissionChart.xAxis.labelRotationAngle = 0
        emissionChart.xAxis.labelTextColor = Constants.colors[State.shared.currentType]!
        
        let maxValue = Double(emissionLog.max()!)
        
        var yAxisValues = [String]()
        for i in 0..<Int(max(Constants.maxValues[State.shared.currentType]!, maxValue)) {
            if i == Int(Constants.maxValues[State.shared.currentType]!) {
                yAxisValues.append(NSLocalizedString("high", comment: "High"))
            }
            else {
                yAxisValues.append("\(i) µg/m³")
            }
        }
        
        emissionChart.leftAxis.valueFormatter = IndexAxisValueFormatter(values:yAxisValues)
        emissionChart.leftAxis.setLabelCount(3, force: false)
        emissionChart.leftAxis.labelTextColor = Constants.colors[State.shared.currentType]!
        emissionChart.leftAxis.axisMaximum = max(Constants.maxValues[State.shared.currentType]!, maxValue)
        
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
            let color = Constants.colors[State.shared.currentType]!.withAlphaComponent(fraction)
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
        backgroundLine.colors = [Constants.colors[State.shared.currentType]!.withAlphaComponent(0.2)]
        
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
    
}

