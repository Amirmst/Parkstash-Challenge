//
//  DataManager.swift
//  Parkstash Challenge
//
//  Created by amir reza mostafavi on 1/23/18.
//  Copyright © 2018 Amir Mostafavi. All rights reserved.
//

import Foundation
import CoreLocation

class DataManager {
    
    static let shared = DataManager()
    
    var data = [CLLocation]()
    
    func loadData() {
        if let array = UserDefaults.standard.array(forKey: "data") as? [[String: Double]] {
            let locations: [CLLocation] = array.flatMap { location in
                if let lat = location["lat"], let long = location["long"] {
                    return CLLocation(latitude: lat, longitude: long)
                }
                return nil
            }
            self.data = locations
        } else {
            
                self.data =  [ CLLocation(latitude: 37.340685, longitude: -121.879236), CLLocation(latitude: 37.343077, longitude: -121.884191), CLLocation(latitude: 37.340621, longitude: -121.867969), CLLocation(latitude: 37.348741, longitude: -121.871402) ]
                self.saveData()
            
        }
    }
    
    func saveData() {
        let array = data.map { location in
            return ["lat": location.coordinate.latitude, "long": location.coordinate.longitude]
        }
        UserDefaults.standard.set(array, forKey: "data")
    }
    
}

