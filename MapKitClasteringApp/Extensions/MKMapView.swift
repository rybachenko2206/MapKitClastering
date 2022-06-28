//
//  MKMapView.swift
//  MapKitClasteringApp
//
//  Created by Roman Rybachenko on 28.06.2022.
//

import Foundation
import MapKit

extension MKMapView {
    func visibleAnnotations() -> [MKAnnotation] {
        annotations(in: visibleMapRect).map { obj -> MKAnnotation in return obj as! MKAnnotation }
    }
}
