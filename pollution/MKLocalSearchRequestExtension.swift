//
//  MKLocalSearchRequestExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 25.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import MapKit

extension MKLocalSearchRequest {
    
    func performLocationSearch(forLocation location: String, alertPresentationController controller: UIViewController, completion: @escaping (_ coordinate: CLLocationCoordinate2D?) -> ()) {
    
        var localSearch: MKLocalSearch!
        
        controller.dismiss(animated: true, completion: nil)

        self.naturalLanguageQuery = location
        localSearch = MKLocalSearch(request: self)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil {
                let alertController = UIAlertController(title: NSLocalizedString("noLocationFound", comment: ""), message: NSLocalizedString("searchQueryDidNotResult", comment: ""), preferredStyle: UIAlertControllerStyle.alert) //
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) {
                    (result : UIAlertAction) -> Void in
                }
                
                alertController.addAction(okAction)
                controller.present(alertController, animated: true, completion: nil)
                
                completion(nil)
            }
            let coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            
            completion(coordinate)
        }
    }
    
}
