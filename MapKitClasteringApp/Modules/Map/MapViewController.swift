//
//  MapViewController.swift
//  MapKitClasteringApp
//
//  Created by Roman Rybachenko on 11.06.2022.
//

import UIKit
import Combine

class MapViewController: UIViewController, Storyboardable {
    // MARK: - Outlets
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    static var storyboardName: Storyboard { .main }
    var viewModel: PMapViewModel?
    
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: - Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        viewModel?.fetchHotspots()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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
    }
}
