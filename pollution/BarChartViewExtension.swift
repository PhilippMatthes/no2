//
//  ChartsExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 14.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import Charts


enum BarChartStyle {
    case whiteOnColor
    case colorOnWhite
}


extension BarChartView {
    
    func setUpChart(intraday: Bool, entries: [PollutionDataEntry], type: BarChartStyle) {
        self.chartDescription?.text = nil
        self.leftAxis.axisMinimum = 0
        self.rightAxis.enabled = false
        self.drawBordersEnabled = false
        self.legend.enabled = false
        self.leftAxis.drawGridLinesEnabled = true
        self.leftAxis.gridColor = UIColor.white
        self.leftAxis.labelTextColor = UIColor.white
        self.leftAxis.axisLineColor = UIColor.white
        self.isUserInteractionEnabled = false
        self.xAxis.drawGridLinesEnabled = false
        self.xAxis.drawAxisLineEnabled = false
        self.noDataTextColor = UIColor.white
        self.noDataText = NSLocalizedString("noData", comment: "No Data available")
        self.updateChart(intraday: intraday, entries: entries, type: type)
    }
    
    func updateChart(intraday: Bool, entries: [PollutionDataEntry], type: BarChartStyle) {
        
        let labelWidth = 27 as CGFloat
        let labelHeight = 12 as CGFloat
        
        var barColor: UIColor?
        switch type {
            case .whiteOnColor:
                self.xAxis.labelTextColor = UIColor.white
                self.leftAxis.labelTextColor = UIColor.white
                barColor = UIColor.white
                self.noDataTextColor = UIColor.white
            case .colorOnWhite:
                self.xAxis.labelTextColor = State.shared.currentColor
                self.leftAxis.labelTextColor = State.shared.currentColor
                barColor = State.shared.currentColor
                self.noDataTextColor = State.shared.currentColor
        }
        
        var backgroundLog = [Double]()
        var emissionLog = [Double]()
        var dateLog = [String]()
        
        for measurementList in entries {
            for measurement in measurementList.measurements {
                if measurement.type == State.shared.currentType {
                    guard
                        let value = measurement.value,
                        let unit = measurement.unit
                    else {
                        print("BCVE: Value or unit could not be extracted")
                        return
                    }
                    
                    if !Constants.supportedUnits.contains(unit) {
                        print("BCVE: Unrecognized unit parsed: \(unit)")
                        return
                    }
                    
                    backgroundLog.append(Constants.maxValues[unit]![State.shared.currentType]!)
                    
                    emissionLog.append(value)
                    
                    
                    let localTime = measurement.getLocalTimeString()
                    
                    let date = String(measurement.date!.prefix(10))
                    let convertedDateString = Date.translateDate(fromDateFormat: "yyyy-MM-dd",
                                                                 toDateFormat: NSLocalizedString("shortDateFormat",
                                                                                                 comment: "Date format"),
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
            self.data = nil
            self.notifyDataSetChanged()
            return
        }
        
        self.xAxis.valueFormatter = IndexAxisValueFormatter(values:dateLog)
        let labelCountInXDirection = Int(self.frame.width/(labelWidth * 3))

        self.xAxis.setLabelCount(labelCountInXDirection, force: false)
        self.xAxis.labelRotationAngle = 0
        
        let maxValue = Double(emissionLog.max()!)
        
        var yAxisValues = [String]()
        for i in 0..<Int(max(Constants.maxValues[State.shared.currentUnit]![State.shared.currentType]!, maxValue)) {
            if i == Int(Constants.maxValues[State.shared.currentUnit]![State.shared.currentType]!) {
                yAxisValues.append(NSLocalizedString("high", comment: "High"))
            }
            else {
                yAxisValues.append("\(i) \(State.shared.currentUnit)")
            }
        }
        
        self.leftAxis.valueFormatter = IndexAxisValueFormatter(values:yAxisValues)
        let labelCountInYDirection = Int(self.frame.height/(labelHeight * 3))
        self.leftAxis.setLabelCount(labelCountInYDirection, force: false)
        self.leftAxis.axisMaximum = max(Constants.maxValues[State.shared.currentUnit]![State.shared.currentType]!, maxValue)
        
        var barChartEntries = [BarChartDataEntry]()
        var backgroundChartEntries = [BarChartDataEntry]()
        var barChartColors = [UIColor]()
        
        for i in 0..<emissionLog.count {
            let emission = emissionLog[i]
            let value = BarChartDataEntry(x: Double(i), y: Double(emission))
            barChartEntries.insert(value, at: 0)
            
            var fraction = CGFloat(0.0)
            if maxValue != 0.0 {
                fraction = min(0.7,CGFloat(Double(emission)/maxValue))
            }
            let color = barColor!.withAlphaComponent(fraction)
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
        backgroundLine.colors = [barColor!.withAlphaComponent(0.2)]
        
        let data = BarChartData()
        
        data.addDataSet(emissionLine)
        data.addDataSet(backgroundLine)
        
        data.setDrawValues(false)
        
        animate(xAxisDuration: 1.0, yAxisDuration: 2.0, easingOption: .easeOutBack)
        
        let limit = Constants.maxValues[State.shared.currentUnit]![State.shared.currentType]!
        let limitAsString = String(Constants.maxValues[State.shared.currentUnit]![State.shared.currentType]!)
        let limitLabel = "\(NSLocalizedString("limit", comment: "")) \(limitAsString) \(State.shared.currentUnit)"
        let limitLine = ChartLimitLine(limit: limit, label: limitLabel)
        limitLine.labelPosition = .rightBottom
        
        switch type {
            case .colorOnWhite:
                limitLine.lineColor = UIColor.black
                limitLine.valueTextColor = UIColor.black
            case .whiteOnColor:
                limitLine.lineColor = UIColor.white
                limitLine.valueTextColor = UIColor.white
            
        }
        for line in leftAxis.limitLines {
            leftAxis.removeLimitLine(line)
        }
        leftAxis.addLimitLine(limitLine)
        
        self.data = data
        self.notifyDataSetChanged()
        
        self.noDataText = NSLocalizedString("noData", comment: "No Data available")
    }
    
}
