//
//  AppError.swift
//  MapKitClasteringApp
//
//  Created by Roman Rybachenko on 11.06.2022.
//

import Foundation

enum AppError: Error, LocalizedError {
    case custom(String)
    case parseResponseModel(String?)
    case defaultError
    
    var localizedDescription: String {
        switch self {
        case .custom(let message):
            return message
        case .parseResponseModel(let errorInfo):
            return "Decoding Error: \(errorInfo ?? "no information")"
        case .defaultError:
            return "Something went wrong. Try again later"
        }
    }
    
    init(error: Error?) {
        guard let error = error else {
            self = .defaultError
            return
        }
        self = .custom(error.localizedDescription)
    }
}
