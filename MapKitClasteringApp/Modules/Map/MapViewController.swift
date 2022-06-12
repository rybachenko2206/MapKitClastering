//
//  MapViewController.swift
//  MapKitClasteringApp
//
//  Created by Roman Rybachenko on 11.06.2022.
//

import UIKit
import Combine
import MapKit

class MapViewController: UIViewController, Storyboardable {
    // MARK: - Outlets
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var mapView: MKMapView!
    
    // MARK: - Properties
    static var storyboardName: Storyboard { .main }
    var viewModel: PMapViewModel?
    
    
    private let defaultDistance = CLLocationDistance(20_000)
    private let locationManager = CLLocationManager()
    private var subscriptions: Set<AnyCancellable> = []
    
    let initialCoordinate = CLLocationCoordinate2D(latitude: 50.449792, longitude: 30.523192)

    // MARK: - Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationServices()
        setupMapView()
        bindViewModel()
        
        viewModel?.fetchHotspots()
    }
    
    // MARK: - Private funcs
    private func bindViewModel() {
        title = viewModel?.title
        
        viewModel?.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            })
            .store(in: &subscriptions)

        viewModel?.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                AlertManager.showAlert(with: error, to: self)
            })
            .store(in: &subscriptions)
        
        viewModel?.hotspotsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] hotspots in
                self?.mapView.addAnnotations(hotspots)
            })
            .store(in: &subscriptions)
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.showsScale = true
        mapView.showsUserLocation = true
        
        let region = MKCoordinateRegion(center: initialCoordinate, latitudinalMeters: defaultDistance, longitudinalMeters: defaultDistance)
        mapView.setRegion(region, animated: true)
        
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: ClusterAnnotationView.reuseId)
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            requestLocationAccess()
        } else {
            // TODO: show warning
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    private func requestLocationAccess() {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            showCurrentLocation()
            break
        case .denied, .restricted:
            // TODO: show alert what's happened
            pl("location access is denied(restricted)")

        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func showCurrentLocation() {
        guard let coordinates = locationManager.location?.coordinate else { return }
        let locationRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: defaultDistance, longitudinalMeters: defaultDistance)
        mapView.setRegion(locationRegion, animated: false)
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        showCurrentLocation()
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        } else if let hotspotAnnotation = annotation as? Hotspot {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Hotspot.annotationId) ?? MKAnnotationView()
            annotationView.annotation = hotspotAnnotation
            annotationView.image = UIImage(systemName: "wifi.circle")
            annotationView.clusteringIdentifier = Hotspot.clusterId
            annotationView.displayPriority = .defaultLow
            return annotationView
        }
        // default cluster annotation view
//        else if let cluster = annotation as? MKClusterAnnotation {
//            let reuseId = "defaultClusterAnnotationView"
//            let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) ?? MKAnnotationView(annotation: cluster, reuseIdentifier: reuseId)
//            clusterView.annotation = cluster
//            clusterView.image = UIImage(systemName: "wifi.square.fill")
//            return clusterView
//        }
        
        // Custom cluster annotation view
        else if let cluster = annotation as? MKClusterAnnotation {
            let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: ClusterAnnotationView.reuseId)
            ?? MKAnnotationView(annotation: annotation, reuseIdentifier: ClusterAnnotationView.reuseId)
            
            clusterView.annotation = cluster
            
            return clusterView
        }
        else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        pf()
        guard view is ClusterAnnotationView else { return }
//        guard view.reuseIdentifier == "defaultClusterAnnotationView" else { return }
        let currentSpan = mapView.region.span
        let zoomSpan = MKCoordinateSpan(latitudeDelta: currentSpan.latitudeDelta / 2.0, longitudeDelta: currentSpan.longitudeDelta / 2.0)
        let zoomCoordinate = view.annotation?.coordinate ?? mapView.region.center
        let zoomed = MKCoordinateRegion(center: zoomCoordinate, span: zoomSpan)
        mapView.setRegion(zoomed, animated: true)
    }
}
