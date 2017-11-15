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

    var isLoading = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = false
        isHidden = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func getDataIfNecessary(withTimeSpanInDays days: Int, intraday: Bool, completionHandler: @escaping () -> ()) {
        
        isLoading = true
        
        let mostRecentMeasurement = station!.entries.first!.getMostRecentMeasurement()
        let mostRecentDate = mostRecentMeasurement?.getConvertedDate()
        
        let toDate = Calendar.current.date(byAdding: .day, value: -days, to: mostRecentDate!)!
        
        DispatchQueue.global(qos: .default).async {
            HiddenDatabaseCaller.makeLocalRequest(forLocation: self.station!.entries.first!.location!,                                                   withLimit: 10000, toDate:  toDate, fromDate: mostRecentDate!) {
                entries in
                self.station?.entries = entries
                DispatchQueue.main.async {
                    self.layoutIfNeeded()
                    self.emissionChart.setUpChart(intraday: days == 1,
                                                  entries: entries,
                                                  type: .colorOnWhite)
                    self.isLoading = false
                    completionHandler()
                }
            }
        }
    }
    
}

