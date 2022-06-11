//
//  Hotspot.swift
//  MapKitClasteringApp
//
//  Created by Roman Rybachenko on 11.06.2022.
//

import Foundation

struct Hotspot: Identifiable {
    let id: Int
    let lat: Double
    let long: Double
    
    init?(with string: String) {
        let components = string.components(separatedBy: ",")
        guard let idComp = components[safe: 1], let identifier = Int(idComp),
              let latComp = components[safe: 2], let latitude = Double(latComp),
              let longComp = components[safe: 3], let longitude = Double(longComp)
        else { return nil }
        
        id = identifier
        lat = latitude
        long = longitude
    }
}
