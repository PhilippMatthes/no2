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
        self.layoutIfNeeded()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

