//
//  ViewController.swift
//  pollution
//
//  Created by Philipp Matthes on 26.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchButtonBackground: UIView!
    @IBOutlet weak var unitLabelBackground: UIProgressView!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var map = [PollutionAnnotation]()
    var overlays = [MKCircle]()
    var maxvalue: Double?
    var currentType: String?
    var requestSent = false
    
    fileprivate var searchController: UISearchController!
    fileprivate var localSearchRequest: MKLocalSearchRequest!
    fileprivate var localSearch: MKLocalSearch!
    fileprivate var localSearchResponse: MKLocalSearchResponse!
    
    fileprivate var annotation: MKAnnotation!
    fileprivate var locationManager: CLLocationManager!
    fileprivate var isCurrentLocation: Bool = false
    fileprivate var activityIndicator: UIActivityIndicatorView!
    
    var selectedAnnotation: PollutionAnnotation?


    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        initUI()
        self.updateAnnotations(withType: currentType!)
    }

    
    @IBAction func searchButtonAction(_ sender: UIButton) {
        searchButtonBackground.animateButtonPress(withBorderColor: UIColor.white, width: 4.0, andDuration: 0.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.searchButtonBackground.animateButtonRelease(withBorderColor: UIColor.white, width: 4.0, andDuration: 0.1)
        })
        if searchController == nil {
            searchController = UISearchController(searchResultsController: nil)
        }
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.barStyle = .default
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.tintColor = Constants.colors[currentType!]!
        searchController.searchBar.barTintColor = UIColor.white
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.gray
        present(searchController, animated: true, completion: nil)
    }
    
    @IBAction func didTypMapView(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        let point = MKMapPointForCoordinate(locationCoordinate)
        let mapRect = MKMapRectMake(point.x, point.y, 0, 0);
        
        for polygon in 0..<mapView.overlays.count {
            if let circle = mapView.overlays[polygon] as? MKCircle {
                if circle.intersects(mapRect) {
                    let newCircle = MKCircle(center: circle.coordinate, radius: circle.radius+(circle.radius/10))
                    
                    let alertController = UIAlertController(title: "Measurement selection.", message: "Select the corresponding measurement to display more information.", preferredStyle: UIAlertControllerStyle.actionSheet)
                    
                    alertController.view.tintColor = UIColor.gray
                    
                    for annotation in map {
                        if annotation.coordinate.latitude == circle.coordinate.latitude {
                            if annotation.coordinate.longitude == circle.coordinate.longitude {
                                let mostRecentMeasurement = annotation.entry!.getMostRecentMeasurement()!
                                
                                let dateString = String(mostRecentMeasurement.date!.prefix(10))
                                
                                var titleString = "\(annotation.title!) (\(dateString))"
                                if mostRecentMeasurement.wasUpdatedToday() {
                                    titleString = "\(annotation.title!) (Today)"
                                }
                                
                                let menuAction = UIAlertAction (
                                    title: titleString,
                                    style: UIAlertActionStyle.default
                                ) {
                                    (action) -> Void in
                                    self.selectedAnnotation = annotation
                                    self.performSegue(withIdentifier: "showDetail", sender: self)
                                }
                                
                                var locationAlreadyInController = false
                                for action in alertController.actions {
                                    if action.title! == titleString {
                                        locationAlreadyInController = true
                                    }
                                }
                                if !locationAlreadyInController {
                                    alertController.addAction(menuAction)
                                }
                                
                                
                            }
                        }
                    }
                    
                    let cancelButtonAction = UIAlertAction (
                        title: "Cancel",
                        style: UIAlertActionStyle.cancel
                    ) {
                        (action) -> Void in
                    }
                    
                    alertController.addAction(cancelButtonAction)
                    
                    let popOver = alertController.popoverPresentationController
                    popOver?.sourceView = view
                    popOver?.sourceRect = view.bounds
                    popOver?.permittedArrowDirections = UIPopoverArrowDirection.any
                    
                    newCircle.title = circle.title
                    newCircle.subtitle = circle.subtitle
                    mapView.add(newCircle)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.mapView.remove(newCircle)
                    })
                    
                    if presentedViewController == nil {
                        self.present(alertController, animated: true, completion: nil)
                        return
                    } else{
                        self.dismiss(animated: true) { () -> Void in
                            self.present(alertController, animated: true, completion: nil)
                            return
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        if self.mapView.annotations.count != 0 {
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { [weak self] (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil {
                let alertController = UIAlertController(title: "No location found.", message: "Your search query did not result in any locations to be displayed. Please try again.", preferredStyle: UIAlertControllerStyle.alert) //Replace UIAlertControllerStyle.Alert by UIAlertControllerStyle.alert
                
                // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) {
                    (result : UIAlertAction) -> Void in
                }
                
                alertController.addAction(okAction)
                self?.present(alertController, animated: true, completion: nil)
                return
            }
            
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.title = searchBar.text
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            
            let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
            self!.mapView.setCenter(pointAnnotation.coordinate, animated: true)
            self!.mapView.addAnnotation(pinAnnotationView.annotation!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func infoButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "showUnitInformation", sender: sender)
    }
    
    @objc func calloutTapped(sender:UITapGestureRecognizer) {
        let view = sender.view as! MKAnnotationView
        if let annotation = view.annotation as? PollutionAnnotation {
            print(annotation.entry!.distance!)
        }
    }
    
    func initUI() {
        
        unitLabelBackground.progressViewStyle = .bar
        unitLabelBackground.setProgress(0.0, animated: true)
        unitLabelBackground.progressTintColor = UIColor.white.withAlphaComponent(0.5)
        unitLabelBackground.clipsToBounds = true
        
        currentType = Constants.units.first
        unitLabel.text = currentType?.capitalized
        unitLabelBackground.layer.backgroundColor = Constants.colors[currentType!]!.cgColor
        searchButtonBackground.layer.backgroundColor = Constants.colors[currentType!]?.cgColor
        maxvalue = Constants.maxValues[currentType!]
        
        unitLabelBackground.layer.cornerRadius = Constants.cornerRadius
        searchButtonBackground.layer.cornerRadius = Constants.cornerRadius
        
        let unitButtonRecognizer = UITapGestureRecognizer(target: self, action:  #selector (self.unitButtonClicked(sender:)))
        unitLabelBackground.addGestureRecognizer(unitButtonRecognizer)
        
        view.addSubview(unitLabelBackground)
        
        unitLabelBackground.layer.zPosition = 100
        searchButtonBackground.layer.zPosition = 100
        
        view.addSubview(mapView)
        mapView.addSubview(unitLabelBackground)
        mapView.addSubview(searchButtonBackground)
    }
    
    
    
    @objc func unitButtonClicked(sender:UITapGestureRecognizer) {
        
        let index = (Constants.units.index(of: currentType!)! + 1) % Constants.units.count
        currentType = Constants.units[index]
        unitLabel.text = currentType!.capitalized
        unitLabelBackground.layer.backgroundColor = Constants.colors[currentType!]?.cgColor
        searchButtonBackground.layer.backgroundColor = Constants.colors[currentType!]?.cgColor
        
        updateAnnotations(withType: currentType!)
        
        unitLabelBackground.animateButtonPress(withBorderColor: UIColor.white, width: 4.0, andDuration: 0.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.unitLabelBackground.animateButtonRelease(withBorderColor: UIColor.white, width: 4.0, andDuration: 0.1)
        })
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        updateAnnotations(withType: currentType!)
    }
    
    func updateAnnotations(withType type: String) {
        
        unitLabelBackground.setProgress(0.8, animated: true)
        
        mapView.removeAnnotations(map)
        map.removeAll()
        
        let radius = getRadius(ofRegion: mapView.region)
        let span = mapView.region.span
        let delta = (span.latitudeDelta + span.longitudeDelta) * 10
        
        
        DispatchQueue.global(qos: .default).async {
            self.requestSent = true
            var currentProgress = 0.0 as Float
            DispatchQueue.main.async {
                currentProgress = self.unitLabelBackground.progress
            }
            
            let limit = 1000
            
            let request = DatabaseCaller.makeLatestRequest(forLongitude: self.mapView.region.center.longitude,
                                       forLatitude: self.mapView.region.center.latitude,
                                       forRadius: Int(radius),
                                       withLimit: limit)
            
            let progressIncrement = (1-currentProgress)/Float(request.count)
            
            
            for entry in request{
                currentProgress += progressIncrement
                DispatchQueue.main.async {
                    self.unitLabelBackground.setProgress(currentProgress, animated: false)
                }
                
                let annotation = DatabaseCaller.generateMapAnnotation(entry: entry)
                self.mapView.addAnnotation(annotation)
                self.map.append(annotation)
            }
            
            DispatchQueue.main.async {
                self.mapView.removeOverlays(self.overlays)
                self.overlays.removeAll()
                
                for annotation in self.map {
                    for measurement in annotation.entry!.measurements! {
                        if measurement.type! == type {
                            self.addCircle(withRadius: radius/delta,
                                           location: CLLocation(latitude: annotation.coordinate.latitude,
                                                                longitude: annotation.coordinate.longitude),
                                           andPercentage: measurement.value!/self.maxvalue!,
                                           andType: type)
                        }
                    }
                }
                
                self.requestSent = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.unitLabelBackground.setProgress(0.0, animated: true)
            })
            
        }
    }
    
    func getRadius(ofRegion region: MKCoordinateRegion) -> Double {
        let center = region.center
        let span = region.span
        
        let loc1 = CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc2 = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc3 = CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta * 0.5)
        let loc4 = CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta * 0.5)
        
        let metersInLatitude = loc1.distance(from: loc2)
        let metersInLongitude = loc3.distance(from: loc4)
        
        return max(metersInLatitude, metersInLongitude)/2
    }
    
    func addCircle(withRadius radius: Double, location: CLLocation, andPercentage percentage: Double, andType type: String){
        let circle = MKCircle(center: location.coordinate, radius: radius)
        circle.title = String(percentage)
        circle.subtitle = type
        self.mapView.add(circle)
        self.overlays.append(circle)
    }
    

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUnitInformation" {
            let vc = segue.destination as! UnitInformationController
            vc.previousViewController = self
            vc.initDesign(withColor: Constants.colors[currentType!]!, andUnit: currentType!)
        }
        if segue.identifier == "showDetail" {
            let vc = segue.destination as! DetailController
            vc.previousViewController = self
            vc.annotationThatWasClicked = selectedAnnotation
            vc.initDesign(withColor: Constants.colors[currentType!]!, andUnit: currentType!)
        }
    }

}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.updateAnnotations(withType: currentType!)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view:MKAnnotationView) {
        let tapGesture = UITapGestureRecognizer(target:self,  action:#selector(calloutTapped(sender:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.removeGestureRecognizer(view.gestureRecognizers!.first!)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        // Better to make this class property
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
            annotationView.image = nil
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let colorOverlay = overlay as? MKCircle {
            let circle = MKCircleRenderer(overlay: colorOverlay)
            
            var percentage = max(0.6, Double(colorOverlay.title!)!)
            percentage = min(1, Double(colorOverlay.title!)!)
            
            circle.strokeColor = Constants.colorLowStroke.interpolateRGBColorTo(end: Constants.colorHighStroke, fraction: CGFloat(percentage))
            circle.fillColor = Constants.colors[colorOverlay.subtitle!]?.withAlphaComponent(CGFloat(percentage))
            
            circle.lineWidth = 1
            return circle
        } else {
            return MKPolylineRenderer()
        }
    }
}

extension UIView {
    func animateButtonPress(withBorderColor color: UIColor, width: Double, andDuration duration: Double) {
        let borderWidth:CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderWidth.fromValue = 0
        borderWidth.toValue = width
        borderWidth.duration = duration
        self.layer.borderWidth = 0.0
        self.layer.borderColor = color.cgColor as CGColor
        self.layer.add(borderWidth, forKey: "Width")
        self.layer.borderWidth = 4.0
    }
    
    func animateButtonRelease(withBorderColor color: UIColor, width: Double, andDuration duration: Double) {
        let borderWidth:CABasicAnimation = CABasicAnimation(keyPath: "borderWidth")
        borderWidth.fromValue = width
        borderWidth.toValue = 0
        borderWidth.duration = duration
        self.layer.borderWidth = 4.0
        self.layer.borderColor = color.cgColor as CGColor
        self.layer.add(borderWidth, forKey: "Width")
        self.layer.borderWidth = 0.0
    }
}


