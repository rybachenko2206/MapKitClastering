//
//  Hotspot.swift
//  MapKitClasteringApp
//
//  Created by Roman Rybachenko on 11.06.2022.
//

import Foundation
import MapKit

class Hotspot: NSObject, Identifiable, MKAnnotation {
    
    let id: Int
    
    let title: String? = nil
    let subtitle: String? = nil
    let coordinate: CLLocationCoordinate2D
    
    static let annotationId = "HotspotAnnotationId"
    static let clusterId = "HotspotClusterId"
    
    init(id: Int, lat: Double, lon: Double) {
        self.id = id
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    init?(with string: String) {
        let components = string.components(separatedBy: ",")
        guard let idComp = components[safe: 1], let identifier = Int(idComp),
              let latComp = components[safe: 2], let latitude = Double(latComp),
              let longComp = components[safe: 3], let longitude = Double(longComp)
        else { return nil }
        
        id = identifier
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
