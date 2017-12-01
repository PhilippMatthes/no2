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
import SwiftRater
import RevealingSplashView
import DTMHeatmap
import SafariServices

class ViewController: UIViewController, UISearchBarDelegate, UIPopoverPresentationControllerDelegate {
    
    
    
    @IBOutlet weak var searchButtonBackground: UIView!
    @IBOutlet weak var unitLabelBackground: UIProgressView!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var heatMap = DTMHeatmap()
    
    var map = [PollutionAnnotation]()
    var overlays = [MKCircle]()
    var maxvalue: Double?
    var requestSent = false
    var tileRenderer: MKTileOverlayRenderer?
    
    fileprivate var searchController: UISearchController!
    
    fileprivate var annotation: MKAnnotation!
    fileprivate var locationManager: CLLocationManager!
    fileprivate var isCurrentLocation: Bool = false
    fileprivate var activityIndicator: UIActivityIndicatorView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initUI()
        updateAnnotations(withType: State.shared.currentType)
    }
    
    override func viewDidLayoutSubviews() {
        unitLabelBackground.roundCorners([.bottomLeft, .bottomRight], withRadius: State.shared.cornerRadius)
        searchButtonBackground.roundCorners([.bottomLeft, .bottomRight], withRadius: State.shared.cornerRadius)
    }
    
    @IBAction func searchButtonAction(_ sender: UIButton) {
        searchButtonBackground.animateClick(withBorderColor: UIColor.white, width: 4.0, andDuration: 0.2)
        if searchController == nil {
            searchController = UISearchController(searchResultsController: nil)
        }
        searchController.initStyle(.whiteClean, withDelegate: self)
        present(searchController, animated: true, completion: nil)
    }
    
    @IBAction func didTapMapView(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        let point = MKMapPointForCoordinate(locationCoordinate)
        let mapRect = MKMapRectMake(point.x, point.y, 0, 0)
        
        let alertController = UIAlertController(title: NSLocalizedString("measurementSelection", comment: ""), message: NSLocalizedString("selectMeasurement", comment: ""), preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.view.tintColor = State.shared.currentColor
        
        var alertsWithDistances = [(UIAlertAction, Double)]()
        
        for polygon in 0..<mapView.overlays.count {
            if let circle = mapView.overlays[polygon] as? MKCircle {
                if circle.intersects(mapRect) {
                    let newCircle = MKCircle(center: circle.coordinate, radius: circle.radius+(circle.radius/10))
                    
                    for annotation in map {
                        if annotation.coordinate.latitude == circle.coordinate.latitude {
                            if annotation.coordinate.longitude == circle.coordinate.longitude {
                                let mostRecentMeasurement = annotation.entry!.getMostRecentMeasurement()!
                                let annotationLocation = CLLocation(latitude: annotation.coordinate.latitude,
                                                                    longitude: annotation.coordinate.longitude)
                                let tapLocation = CLLocation(latitude: locationCoordinate.latitude,
                                                             longitude: locationCoordinate.longitude)
                                let preciseDistance = annotationLocation.distance(from: tapLocation)
                                let distance = round(preciseDistance/100)/10
                                let dateString = String(mostRecentMeasurement.date!.prefix(10))
                                let convertedDateString = Date.translateDate(fromDateFormat: "yyyy-MM-dd",
                                                                                       toDateFormat: NSLocalizedString("dateFormat", comment: "Date format"),
                                                                                       withDate: dateString)
                                
                                var titleString = "\(annotation.title!) (\(convertedDateString), \(distance) km)"
                                if mostRecentMeasurement.wasUpdatedToday() {
                                    titleString = "\(annotation.title!) (\(NSLocalizedString("today", comment: "Today")), \(distance) km)"
                                }
                                
                                let menuAction = UIAlertAction (
                                    title: titleString,
                                    style: UIAlertActionStyle.default
                                ) {
                                    (action) -> Void in
                                    State.shared.transferAnnotation = annotation
                                    self.performSegue(withIdentifier: "showDetail", sender: self)
                                }
                                
                                alertsWithDistances.append((menuAction, distance))
                            }
                        }
                    }
                    newCircle.title = circle.title
                    newCircle.subtitle = circle.subtitle
                    mapView.add(newCircle)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.mapView.remove(newCircle)
                    })
                }
            }
        }
        
        // Sort alerts
        for alert in alertsWithDistances.sorted(by: {$0.1 < $1.1}) {
            var alertExistsAlready = false
            for action in alertController.actions {
                if alert.0.title! == action.title! {
                    alertExistsAlready = true
                }
            }
            if !alertExistsAlready {
                alertController.addAction(alert.0)
            }
        }
        
        let cancelButtonAction = UIAlertAction (
            title: NSLocalizedString("cancel", comment: "Cancel"),
            style: UIAlertActionStyle.cancel
        ) {
            (action) -> Void in
        }
        
        alertController.addAction(cancelButtonAction)
        
        let popOver = alertController.popoverPresentationController
        popOver?.sourceView = view
        popOver?.sourceRect = view.bounds
        popOver?.permittedArrowDirections = UIPopoverArrowDirection.any

        if presentedViewController == nil {
            if alertController.actions.count != 1 {
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
        } else {
            if alertController.actions.count != 1 {
                self.dismiss(animated: true) { () -> Void in
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
            }
        }
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        mapView.performLocalSearch(forSearchBar: searchBar, onController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func infoButtonClicked(_ sender: UIButton) {
        let url: URL = URL(string: NSLocalizedString(State.shared.currentType+"info", comment: "Link"))!
        let svc = SFSafariViewController(url: url, tintColor: State.shared.currentColor)
        present(svc, animated: true, completion: nil)
    }
    
    @objc func calloutTapped(sender:UITapGestureRecognizer) {
        let view = sender.view as! MKAnnotationView
        if let annotation = view.annotation as? PollutionAnnotation {
            print(annotation.entry!.distance!)
        }
    }
    
    func initUI() {
        view.layoutIfNeeded()
        
        unitLabelBackground.progressViewStyle = .bar
        unitLabelBackground.setProgress(0.0, animated: false)
        unitLabelBackground.progressTintColor = UIColor.white.withAlphaComponent(0.5)
        unitLabelBackground.clipsToBounds = true
        
        unitLabel.text = State.shared.currentType.uppercased()
        
        maxvalue = Constants.maxValues["µg/m³"]![State.shared.currentType]
        
        let unitButtonRecognizer = UITapGestureRecognizer(target: self, action:  #selector (self.unitButtonClicked(sender:)))
        unitLabelBackground.addGestureRecognizer(unitButtonRecognizer)
        
        view.addSubview(mapView)
        
        for background in [unitLabelBackground!, searchButtonBackground!] {
            background.layer.backgroundColor = State.shared.currentColor.withAlphaComponent(Constants.transparency).cgColor
            background.layer.zPosition = 100
            mapView.addSubview(background)
        }
    }
    
    
    @objc func unitButtonClicked(sender:UITapGestureRecognizer) {
        
        let index = (Constants.units.index(of: State.shared.currentType)! + 1) % Constants.units.count
        State.shared.currentType = Constants.units[index]
        unitLabel.text = State.shared.currentType.uppercased()
        tabBarController!.tabBar.animate(toBackgroundColor: State.shared.currentColor.withAlphaComponent(Constants.transparency),
                                         withDuration: 2.0)
        unitLabelBackground.animate(toBackgroundColor: State.shared.currentColor.withAlphaComponent(Constants.transparency), withDuration: 2.0)
        searchButtonBackground.animate(toBackgroundColor: State.shared.currentColor.withAlphaComponent(Constants.transparency), withDuration: 2.0)
        
        updateAnnotations(withType: State.shared.currentType)
        
        unitLabelBackground.animateClick(withBorderColor: UIColor.white, width: 4.0, andDuration: 0.2)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        updateAnnotations(withType: State.shared.currentType)
    }
    
    func updateAnnotations(withType type: String) {
        
        self.mapView.removeAnnotations(self.map)
        self.map.removeAll()
        
        var heatmapdata:[NSObject: Double] = [:]
        let components = State.shared.currentColor.getRGB()!
        heatMap.colorProvider.red(CGFloat(components.red),
                                  green: CGFloat(components.green),
                                  blue: CGFloat(components.blue))
        
        unitLabelBackground.setProgress(0.8, animated: true)
        
        let radius = mapView.region.getRadius()
        let span = mapView.region.span
        let delta = pow((span.latitudeDelta + span.longitudeDelta),0.7) * 5
        
        
        DispatchQueue.global(qos: .default).async {
            self.requestSent = true
            var currentProgress = 0.0 as Float
            DispatchQueue.main.async {
                currentProgress = self.unitLabelBackground.progress
            }
            
            let limit = State.shared.numberOfMapResults
            
            DatabaseCaller.makeLatestRequest(forLongitude: self.mapView.region.center.longitude, forLatitude: self.mapView.region.center.latitude, forRadius: Int(radius), withLimit: limit) {
                entries in
                let progressIncrement = (1-currentProgress)/Float(entries.count)
                
                for entry in entries {
                    currentProgress += progressIncrement
                    DispatchQueue.main.async {
                        self.unitLabelBackground.setProgress(currentProgress, animated: false)
                    }
                    
                    let annotation = entry.generateMapAnnotation()
                    self.mapView.addAnnotation(annotation)
                    self.map.append(annotation)
                }
                
                DispatchQueue.main.async {
                    self.mapView.removeOverlays(self.overlays)
                    self.overlays.removeAll()
                    
                    for annotation in self.map {
                        for measurement in annotation.entry!.measurements {
                            if measurement.type == type {
                                self.addCircle(withRadius: radius/delta,
                                               location: CLLocation(latitude: annotation.coordinate.latitude,
                                                                    longitude: annotation.coordinate.longitude),
                                               andPercentage: measurement.value!/self.maxvalue!,
                                               andType: type)
                                
                                let coordinate = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude,
                                                                        longitude: annotation.coordinate.longitude)
                                var point = MKMapPointForCoordinate(coordinate)
                                let type = "{MKMapPoint=dd}"
                                let value = NSValue(bytes: &point, objCType: type)
                                heatmapdata[value] = measurement.value!/self.maxvalue!
                            }
                        }
                    }
                    
                    if State.shared.isHeatmapOn {
                        self.heatMap.setData(heatmapdata as [NSObject : AnyObject])
                        self.mapView.add(self.heatMap)
                    } else {
                        self.mapView.remove(self.heatMap)
                    }
                    
                    self.requestSent = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.unitLabelBackground.setProgress(0.0, animated: true)
                })
            }
        }
    }
    
    
    func addCircle(withRadius radius: Double, location: CLLocation, andPercentage percentage: Double, andType type: String){
        let circle = MKCircle(center: location.coordinate, radius: radius)
        circle.title = String(percentage)
        circle.subtitle = type
        mapView.add(circle, level: .aboveRoads)
        self.overlays.append(circle)
    }
    

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let vc = segue.destination as! DetailController
            vc.previousViewController = self
        }
    }

}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.updateAnnotations(withType: State.shared.currentType)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view:MKAnnotationView) {
        let tapGesture = UITapGestureRecognizer(target:self,  action:#selector(calloutTapped(sender:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.removeGestureRecognizer(view.gestureRecognizers!.first!)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Better to make this class property
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = false
            annotationView.image = nil
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let colorOverlay = overlay as? MKCircle {
            
            
            var percentage = max(0.2, Double(colorOverlay.title!)!)
            percentage = min(0.8, Double(colorOverlay.title!)!)
            
            let color = Constants.colors[colorOverlay.subtitle!]!.withAlphaComponent(CGFloat(percentage))
            
            let circle = CustomCircleRenderer(withOverlay: overlay, withGradientFillColor: color)
            
            circle.lineWidth = 1
            return circle
        } else {
            return DTMHeatmapRenderer.init(overlay: overlay)
        }
    }
}




