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
        animateTransition(for: source, shouldHide: true)
        animateTransition(for: destination, shouldHide: false)
    }

    func animateTransition(for view: UIView, shouldHide: Bool) {
        UIView.transition(with: view, duration: 0.25, options: .defaultTransitionOption) {
            view.isHidden = shouldHide
        }
    }
}

extension UIView.AnimationOptions {
    static let defaultTransitionOption : UIView.AnimationOptions = [.showHideTransitionViews,
                                                                    .transitionFlipFromRight]
}
