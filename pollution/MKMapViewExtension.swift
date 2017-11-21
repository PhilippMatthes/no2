//
//  MapViewExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 21.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import MapKit

extension MKMapView {
    
    func performLocalSearch(forSearchBar searchBar: UISearchBar, onController controller: UIViewController) {
        
        var localSearchRequest: MKLocalSearchRequest!
        var localSearch: MKLocalSearch!
        
        searchBar.resignFirstResponder()
        controller.dismiss(animated: true, completion: nil)
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { [weak self] (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil {
                let alertController = UIAlertController(title: NSLocalizedString("noLocationFound", comment: "No location found."), message: NSLocalizedString("searchQueryDidNotResult", comment: "Your search query did not result in any locations to be displayed. Please try again."), preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
                
                // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) {
                    (result : UIAlertAction) -> Void in
                }
                
                alertController.addAction(okAction)
                controller.present(alertController, animated: true, completion: nil)
                return
            }
            let coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            
            self!.setCenter(coordinate, animated: true)
        }
    }
    
}
