//
//  CustomMapOverlay.swift
//  pollution
//
//  Created by Philipp Matthes on 01.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import MapKit

class CustomMapOverlay: MKTileOverlay {
    
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let tileUrl = "https://tile.openstreetmap.org/\(path.z)/\(path.x)/\(path.y).png"
        return URL(string: tileUrl)!
    }
}
