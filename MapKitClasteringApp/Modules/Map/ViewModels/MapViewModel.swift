//
//  MapViewModel.swift
//  MapKitClasteringApp
//
//  Created by Roman Rybachenko on 11.06.2022.
//

import Foundation
import Combine
import MapKit

protocol PMapViewModel: DataLoadable {
    var title: String { get }
    var visibleMapRect: MKMapRect? { get set }
    var hotspotsPublisher: AnyPublisher<[Hotspot], Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<AppError, Never> { get }
    
    func setIsLoading(_ isLoading: Bool)
    func fetchHotspots()
}

class MapViewModel: PMapViewModel {
    // MARK: - Properties
    private let csvFileManager: CSVFileManagerProtocol
    
    private var allHotspots: [Hotspot] = []
    private var addedHotspots: Set<Hotspot> = []
    
    @Published private var filteredHotspots: [Hotspot] = []
    @Published private var isLoading: Bool = false
    @Published private var error: AppError?
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<AppError, Never> {
        $error
            .compactMap({ $0 })
            .eraseToAnyPublisher()
    }
    
    var hotspotsPublisher: AnyPublisher<[Hotspot], Never> {
        $filteredHotspots.eraseToAnyPublisher()
    }
    
    var visibleMapRect: MKMapRect? {
        didSet {
            if let oldMapRect = oldValue,
                let newMapRect = visibleMapRect,
               oldMapRect.contains(newMapRect)
            { return }
            
            filterAnnotations()
        }
    }
    
    let title = "Hotspots"
    
    // MARK: - Init
    init(csvFileManager: CSVFileManagerProtocol) {
        self.csvFileManager = csvFileManager
    }
    
    // MARK: - Public funcs
    func setIsLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    func fetchHotspots() {
        isLoading = true
        
        csvFileManager.fetchHotspots(completion: { [weak self] hotspots in
            guard let self = self else { return }
            self.isLoading = false
            self.allHotspots = hotspots
            self.filterAnnotations()
        }, failure: { [weak self] error in
            self?.isLoading = false
            self?.error = error
        })
    }
    
    
    // MARK: - Private funcs
    private func filterAnnotations() {
        guard allHotspots.count > 0, let mapRect = visibleMapRect else { return }
        isLoading = true
        
        let bgQueue = DispatchQueue(label: "bgQueue", qos: .userInteractive)
        bgQueue.async { [weak self] in
            guard let self = self else { return }
            
            let filteredArray = self.allHotspots.filter({ mapRect.contains(MKMapPoint($0.coordinate)) })
            var filteredSet = Set(filteredArray)
            filteredSet = filteredSet.subtracting(self.addedHotspots)
            
            self.filteredHotspots = Array(filteredSet)
            self.addedHotspots = self.addedHotspots.union(filteredSet)
            self.isLoading = false
        }
    }
}
