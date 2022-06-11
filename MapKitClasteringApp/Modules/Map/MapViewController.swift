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
    
    
    private let defaultDistance = CLLocationDistance(3_000_000)
    private let locationManager = CLLocationManager()
    private var subscriptions: Set<AnyCancellable> = []
    
    let testLocation = CLLocationCoordinate2D(latitude: 48.922583, longitude: 24.710411)

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
        case .denied, .restricted:
            // TODO: show alert what's happened
            pl("location access is denied(restricted)")

        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func showCurrentLocation() {
        guard let coordinates = locationManager.location?.coordinate else { return }
        var locationRegion = mapView.region
        locationRegion.center = coordinates
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
        if annotation is MKUserLocation { return nil }
        else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            annotationView.image = UIImage(systemName: "wifi.circle")
            return annotationView
        }
    }
}
