//
//  UIViewController+Animation.swift
//  ExQuizIt
//
//  Created by rehnuma.deepty on 24/5/22.
//

import Foundation
import UIKit

extension UIViewController {
    func flipCard(from source: UIView, to destination: UIView) {
        animateTransition(for: source, hideView: true)
        animateTransition(for: destination, hideView: false)
    }

    func animateTransition(for view: UIView, hideView: Bool) {
        UIView.transition(with: view,
                          duration: 0.25,
                          options: .defaultTransitionOption) {
            view.isHidden = hideView
            
        }
    }
}

