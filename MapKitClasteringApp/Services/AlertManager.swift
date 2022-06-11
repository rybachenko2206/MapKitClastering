//
//  AlertManager.swift
//  MapKitClasteringApp
//
//  Created by Roman Rybachenko on 11.06.2022.
//

import Foundation
import UIKit

class AlertManager {
    class func showAlert(with error: AppError, to controller: UIViewController?) {
        let title = "Error"
        simpleAlert(title: title, message: error.localizedDescription, controller: controller)
    }
    
    private class func simpleAlert(title: String, message: String, controller: UIViewController?) {
        guard let viewController = controller else { return }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in })
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
