//
//  MapViewModel.swift
//  MapKitClasteringApp
//
//  Created by Roman Rybachenko on 11.06.2022.
//

import Foundation
import Combine

protocol PMapViewModel: DataLoadable {
    var title: String { get }
    var hotspotsPublisher: AnyPublisher<[Hotspot], Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<AppError, Never> { get }
    
    func fetchHotspots()
}

class MapViewModel: PMapViewModel {
    // MARK: - Properties
    private let csvFileManager: CSVFileManagerProtocol
    
    @Published private var hotspots: [Hotspot] = []
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
        $hotspots.eraseToAnyPublisher()
    }
    
    let title = "Hotspots"
    
    // MARK: - Init
    init(csvFileManager: CSVFileManagerProtocol) {
        self.csvFileManager = csvFileManager
    }
    
    // MARK: - Public funcs
    func fetchHotspots() {
        isLoading = true
        
        csvFileManager.fetchHotspots(completion: { [weak self] hotspots in
            self?.isLoading = false
            self?.hotspots = hotspots
        }, failure: { [weak self] error in
            self?.isLoading = false
            self?.error = error
        })
    }
    
    
    // MARK: - Private funcs
}
