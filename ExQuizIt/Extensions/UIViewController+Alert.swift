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
                   placeHolder: String? = nil,
                   okTitle: String = "Ok",
                   cancelTitle: String? = nil,
                   onConfirm: ((String?) -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let placeHolder = placeHolder {
            alert.addTextField { textField in
                textField.placeholder = placeHolder
            }
        }
        
        let okAction = UIAlertAction(title: okTitle, style: .default) { _ in
            if let textField = alert.textFields?.first as? UITextField {
                onConfirm?(textField.text)
            }
            
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
    
    func showAlertWithTextField(title: String?,
                                message: String?,
                                placeHolder: String,
                                onConfirm: (String)-> ()) {
        
    }
}
