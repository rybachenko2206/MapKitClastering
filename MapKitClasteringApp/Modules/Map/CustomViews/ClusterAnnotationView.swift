//
//  ClusterAnnotationView.swift
//  MapKitClasteringApp
//
//  Created by Roman Rybachenko on 11.06.2022.
//

import UIKit
import MapKit

class ClusterAnnotationView: MKAnnotationView {
    static let reuseId = "ClusterAnnotationView"
    
    override var annotation: MKAnnotation? {
        didSet {
            guard let cluster = annotation as? MKClusterAnnotation else { return }
            displayPriority = .defaultLow
            
            let imageType = ClusterImageType.type(for: cluster.memberAnnotations.count)
            self.image = imageType.image
        }
    }

}

extension ClusterAnnotationView {
    enum ClusterImageType: Int {
        case small = 15
        case medium = 100
        case large = 500
        case extraLarge = 501
        
        var image: UIImage? {
            let image = UIImage(systemName: systemImageName, withConfiguration: imageConfigurations)
            return image
        }
        
        private var imageConfigurations: UIImage.SymbolConfiguration {
            let sizeConfig = UIImage.SymbolConfiguration(pointSize: imagePointSize,
                                                         weight: .regular,
                                                         scale: imageScale)
            return sizeConfig
        }
        
        private var imagePointSize: CGFloat {
            let size: CGFloat
            switch self {
            case .small: size = 15
            case .medium: size = 20
            case .large: size = 26
            case .extraLarge: size = 34
            }
            return size
        }
        
        private var imageScale: UIImage.SymbolScale {
            switch self {
            case .small: return .small
            case .medium: return .medium
            case .large, .extraLarge: return .large
            }
        }
        
        private var systemImageName: String {
            return "wifi.circle.fill"
        }
        
        static func type(for count: Int) -> ClusterImageType {
            if count <= ClusterImageType.small.rawValue {
                return .small
            } else if count <= ClusterImageType.medium.rawValue {
                return .medium
            } else if count <= ClusterImageType.large.rawValue {
                return .large
            } else {
                return .extraLarge
            }
        }
    }
}
