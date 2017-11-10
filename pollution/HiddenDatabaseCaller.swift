//
//  HiddenDatabaseCaller.swift
//  pollution
//
//  Created by Philipp Matthes on 10.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation
import MapKit

class HiddenDatabaseCaller {
    
    static func makeLatestRequest(forLongitude longitude: Double, forLatitude latitude: Double, forRadius radius: Int, withLimit limit: Int, completionHandler: @escaping (_ entries: [PollutionDataEntry]) -> ()) {
        
        var output = [PollutionDataEntry]()
        
        let request = URLRequest(url: NSURL(string: "https://api.openaq.org/v1/latest?has_geo=true&coordinates=\(latitude),\(longitude)&limit=\(limit)&radius=\(radius)")! as URL)
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) -> Void in
            do {
                if let taskData = data {
                    if let jsonSerialized = try JSONSerialization.jsonObject(with: taskData, options: []) as? [String : Any] {
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
                                            }
                                            entry.measurements.append(measurementEntry)
                                        }
                                    }
                                    output.append(entry)
                                }
                            }
                        }
                    }
                }
            } catch {
                print(error)
            }
            completionHandler(output)
            }.resume()
    }
    
    static func makeLocalRequest(forLocation location: String, withLimit limit: Int, toDate dateTo: Date, fromDate dateFrom: Date, completionHandler: @escaping (_ entries: [PollutionDataEntry]) -> ()) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateToString = dateFormatter.string(from:dateTo as Date)
        let dateFromString = dateFormatter.string(from:dateFrom as Date)
        
        var output = [PollutionDataEntry]()
        
        let locationEncoded = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        
        let urlString = "https://api.openaq.org/v1/measurements?has_geo=true&location=\(locationEncoded)&limit=\(limit)&date_from=\(dateToString)&date_to=\(dateFromString)"
        
        print(urlString)
        
        let request = URLRequest(url: NSURL(string: urlString)! as URL)
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) -> Void in
            do {
                if let taskData = data {
                    // Convert the data to JSON
                    if let jsonSerialized = try JSONSerialization.jsonObject(with: taskData, options: []) as? [String : Any] {
                        if let results = jsonSerialized["results"]{
                            if let resultsSerialized = results as? (Array<[String : Any]>) {
                                let entry = PollutionDataEntry()
                                entry.measurements = [PollutionMeasurement]()
                                for result in resultsSerialized {
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
                                    entry.distance = 0
                                    if let location = result["location"] as? String {
                                        entry.location = location
                                    }
                                    if let country = result["country"] as? String {
                                        entry.country = country
                                    }
                                    let measurement = PollutionMeasurement()
                                    if let value = result["value"] as? Double {
                                        measurement.value = value
                                    }
                                    if let unit = result["unit"] as? String {
                                        measurement.unit = unit
                                    }
                                    if let parameter = result["parameter"] as? String {
                                        measurement.type = parameter
                                    }
                                    if let date = result["date"] as? [String: Any] {
                                        if let local = date["local"] as? String {
                                            measurement.date = local
                                        }
                                    }
                                    entry.measurements.append(measurement)
                                }
                                output.append(entry)
                            }
                        }
                    }
                }
            } catch {
                print(error)
            }
            completionHandler(output)
            }.resume()
    }
    
    static func makeNotificationRequest(forLocation location: String, withLimit limit: Int, completionHandler: @escaping (_ entries: [PollutionDataEntry]) -> ()) {
        
        var output = [PollutionDataEntry]()
        
        let locationEncoded = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        
        let urlString = "https://api.openaq.org/v1/measurements?has_geo=true&location=\(locationEncoded)&limit=\(limit)"
        
        print(urlString)
        
        let request = URLRequest(url: NSURL(string: urlString)! as URL)
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) -> Void in
            do {
                if let taskData = data {
                    // Convert the data to JSON
                    if let jsonSerialized = try JSONSerialization.jsonObject(with: taskData, options: []) as? [String : Any] {
                        if let results = jsonSerialized["results"]{
                            if let resultsSerialized = results as? (Array<[String : Any]>) {
                                let entry = PollutionDataEntry()
                                entry.measurements = [PollutionMeasurement]()
                                for result in resultsSerialized {
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
                                    entry.distance = 0
                                    if let location = result["location"] as? String {
                                        entry.location = location
                                    }
                                    if let country = result["country"] as? String {
                                        entry.country = country
                                    }
                                    let measurement = PollutionMeasurement()
                                    if let value = result["value"] as? Double {
                                        measurement.value = value
                                    }
                                    if let unit = result["unit"] as? String {
                                        measurement.unit = unit
                                    }
                                    if let parameter = result["parameter"] as? String {
                                        measurement.type = parameter
                                    }
                                    if let date = result["date"] as? [String: Any] {
                                        if let local = date["local"] as? String {
                                            measurement.date = local
                                        }
                                    }
                                    entry.measurements.append(measurement)
                                }
                                output.append(entry)
                            }
                        }
                    }
                }
            } catch {
                print(error)
            }
            completionHandler(output)
            }.resume()
    }
    
    static func generateMapAnnotation(entry: PollutionDataEntry) -> PollutionAnnotation {
        let annotation = PollutionAnnotation()
        annotation.setCoordinate(newCoordinate: CLLocationCoordinate2D(latitude: entry.latitude!, longitude: entry.longitude!))
        annotation.title = entry.location
        annotation.subtitle = entry.city
        annotation.entry = entry
        return annotation
    }
}
