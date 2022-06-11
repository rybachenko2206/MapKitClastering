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
    
    func fetchHotspots()
}

class MapViewModel: PMapViewModel {
    // MARK: - Properties
    private let csvFileManager: CSVFileManagerProtocol
    
    @Published private var annotations: [Hotspot] = []
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
            self?.annotations = hotspots
        }, failure: { [weak self] error in
            self?.isLoading = false
            self?.error = error
        })
    }
    
    
    // MARK: - Private funcs
}
