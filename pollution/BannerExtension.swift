//
//  BannerExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 21.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import BRYXBanner

enum BannerType {
    case information
    case stationSaved
    case stationUpdated
}

enum BannerStyle {
    case coloredTextOnWhite
    case whiteTextOnColor
}

extension Banner {
    
    func dismissInAllocation() -> Banner {
        dismiss()
        return self
    }
    
    func with(type: BannerType) -> Banner {
        switch type {
            case .information:
                return Banner(title: "Information", subtitle: NSLocalizedString("cellInformation", comment: ""), image: nil, backgroundColor: UIColor.clear)
            case .stationSaved:
                return Banner(title: NSLocalizedString("stationSaved", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.clear)
            case .stationUpdated:
                return Banner(title: NSLocalizedString("stationUpdated", comment: ""), subtitle: nil, image: nil, backgroundColor: UIColor.clear)
        }
        
    }
    
    func andShow(_ type: BannerStyle) -> Banner {
        dismissesOnTap = false
        switch type {
            case .coloredTextOnWhite:
                titleLabel.textColor = State.shared.currentColor
                backgroundColor = UIColor.white
                position = BannerPosition.top
            case .whiteTextOnColor:
                titleLabel.textColor = UIColor.white
                backgroundColor = State.shared.currentColor
                position = BannerPosition.top
        }
        show()
        return self
    }
    
    func andShow(_ type: BannerStyle, duration: TimeInterval) -> Banner {
        dismissesOnTap = true
        switch type {
            case .coloredTextOnWhite:
                titleLabel.textColor = State.shared.currentColor
                backgroundColor = UIColor.white
                position = BannerPosition.top
            case .whiteTextOnColor:
                titleLabel.textColor = UIColor.white
                backgroundColor = State.shared.currentColor
                position = BannerPosition.top
        }
        show(duration: duration)
        return self
    }
    
}
