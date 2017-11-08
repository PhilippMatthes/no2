//
//  InformationCell.swift
//  pollution
//
//  Created by Philipp Matthes on 08.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit


class InformationCell: UITableViewCell {
    
    
    @IBOutlet weak var informationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = false
        self.isHidden = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}

