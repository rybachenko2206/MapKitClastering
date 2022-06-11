//
//  Array.swift
//  BeersTestApp
//
//  Created by Roman Rybachenko on 24.01.2020.
//  Copyright © 2020 Roman Rybachenko. All rights reserved.
//


import Foundation


extension Array {
    subscript (safe index: Int) -> Element? {
        return index < count ? self[index] : nil
    }
    
    func item(at index: Int) -> Element? {
      return indices.contains(index) ? self[index] : nil
    }
}
