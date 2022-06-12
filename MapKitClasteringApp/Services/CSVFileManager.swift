//
//  CSVFileManager.swift
//  MapKitClasteringApp
//
//  Created by Roman Rybachenko on 11.06.2022.
//

import Foundation
import SwiftCSV

protocol CSVFileManagerProtocol {
    func fetchHotspots(completion: @escaping([Hotspot]) -> Void, failure: @escaping ErrorCompletion)
}

typealias ErrorCompletion = (AppError) -> Void

class CSVFileManager: CSVFileManagerProtocol {
    func fetchHotspots(completion: @escaping([Hotspot]) -> Void, failure: @escaping ErrorCompletion) {
        let bgQueue = DispatchQueue.global(qos: .userInitiated)
        bgQueue.async {
            do {
                let csv = try self.fetchCSV(from: "hotspots")
                
                pl("mapping hotspots with strings is started, strings.count = \(csv.header.count), \n at\(Date())")
                let hotspots: [Hotspot] = csv.header.compactMap({ Hotspot(with: $0) })
                
                pl("mapping hotspots with strings is finished, hotspots.count = \(hotspots.count) \n at\(Date())")
                completion(hotspots)
            } catch let appError as AppError {
                failure(appError)
            } catch {
                failure(.custom(error.localizedDescription))
            }
        }
    }
    
    private func fetchCSV(from fileName: String, fileExtension: String = ".csv") throws -> CSV {
        pl("fetch data from .csv file is started \n at\(Date())")
        do {
            let resource: CSV? = try CSV(name: fileName,
                                        extension: fileExtension,
                                        bundle: .main,
                                        delimiter: "\n",
                                        encoding: .utf8,
                                        loadColumns: true)
            
            pl(".csv file is fetched successfully: \(resource != nil) \n at\(Date())")
            guard let csv = resource else {
                assertionFailure("Failed data from .csv file, object is nil")
                throw AppError.defaultError
            }
            return csv
            
        } catch let parseError as CSVParseError {
            pl("error in fetch data from .csv file: \n\(parseError)")
            throw AppError.custom(parseError.localizedDescription)
        } catch {
            pl("error in fetch data from .csv file: \n\(error)")
            throw AppError(error: error)
        }
    }
}
