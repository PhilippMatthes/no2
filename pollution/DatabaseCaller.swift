//
//  DatabaseCaller.swift
//  pollution
//
//  Created by Philipp Matthes on 26.10.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import MapKit


class DatabaseCaller {
    

    static func makeRequest(forLongitude longitude: Double, forLatitude latitude: Double, forRadius radius: Int, withLimit limit: Int) -> [PollutionDataEntry] {
        
        var output = [PollutionDataEntry]()
        
        let request = URLRequest(url: NSURL(string: "https://api.openaq.org/v1/latest?has_geo=true&coordinates=\(latitude),\(longitude)&limit=\(limit)&radius=\(radius)")! as URL)
        do {
            // Perform the request
            
            let response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
            let data = try NSURLConnection.sendSynchronousRequest(request, returning: response)
            
            // Convert the data to JSON
            if let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                if let results = jsonSerialized["results"]{
                    if let resultsSerialized = results as? (Array<[String : Any]>) {
                        for result in resultsSerialized {
                            let entry = PollutionDataEntry()
                            if let city = result["city"] as? String {
                                entry.city = city
                            }
                            if let coordinates = result["coordinates"] as? [String : Any] {
                                if let latitude = coordinates["latitude"] as? Double {
                                    entry.latitude = latitude
                                }
                                if let longitude = coordinates["longitude"] as? Double {
                                    entry.longitude = longitude
                                }
                            }
                            if let distance = result["distance"] as? Double {
                                entry.distance = distance
                            }
                            if let location = result["location"] as? String {
                                entry.location = location
                            }
                            if let country = result["country"] as? String {
                                entry.country = country
                            }
                            if let measurements = result["measurements"] as? Array<Any> {
                                entry.measurements = [PollutionMeasurement]()
                                for measurement in measurements {
                                    let measurementEntry = PollutionMeasurement()
                                    if let measurementDict = measurement as? [String : Any] {
                                        if let lastUpdated = measurementDict["lastUpdated"] as? String {
                                            measurementEntry.date = lastUpdated
                                        }
                                        if let type = measurementDict["parameter"] as? String {
                                            measurementEntry.type = type
                                        }
                                        if let value = measurementDict["value"] as? Double {
                                            if let unit = measurementDict["unit"] as? String {
                                                measurementEntry.unit = unit
                                                measurementEntry.value = value
                                            }
                                        }
                                        if let sourceName = measurementDict["sourceName"] as? String {
                                            measurementEntry.source = sourceName
                                        }
                                        if let averagingPeriod = measurementDict["averagingPeriod"] as? [String : Any] {
                                            if let value = averagingPeriod["value"] as? Double {
                                                if let unit = averagingPeriod["unit"] as? String {
                                                    measurementEntry.rate = String(value)+" "+unit
                                                }
                                            }
                                        }
                                    }
                                    entry.measurements?.append(measurementEntry)
                                }
                            }
                            output.append(entry)
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
        return output
    }
    
    static func generateMapAnnotation(entry: PollutionDataEntry) -> PollutionAnnotation {
        let annotation = PollutionAnnotation()
        annotation.setCoordinate(newCoordinate: CLLocationCoordinate2D(latitude: entry.latitude!, longitude: entry.longitude!))
        var subtitle = ""
        for measurement in entry.measurements! {
            subtitle += String(measurement.value!)+" "+measurement.unit!+", "
        }
        annotation.subtitle = subtitle
        annotation.title = entry.location
        annotation.entry = entry
        return annotation
    }
}
