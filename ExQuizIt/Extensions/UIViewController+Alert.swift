//
//  UIViewController+Alert.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 24/5/22.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String?,
                   message: String?,
                   okTitle: String = "Ok",
                   cancelTitle: String? = nil,
                   onConfirm: (() -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
       
        let okAction = UIAlertAction(title: okTitle, style: .default) { _ in
            onConfirm?()
        }
        
        if let cancelTitle = cancelTitle {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel)
            
            alert.addAction(cancelAction)
        }
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func showToast(title: String?,
                   message: String?,
                   dismissDelay: TimeInterval = 0.25,
                   onDismiss: (() -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + dismissDelay) {
                alert.dismiss(animated: true) {
                    onDismiss?()
                }
            }
        }
    }
}
