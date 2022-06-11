//
//  DataLoadable.swift
//  ContactsTestApp
//
//  Created by Roman Rybachenko on 17.05.2022.
//

import Foundation
import Combine

protocol DataLoadable {
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<AppError, Never> { get }
}

