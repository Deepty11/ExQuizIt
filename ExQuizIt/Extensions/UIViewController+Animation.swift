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
        UIView.transition(from: source,
                          to: destination,
                          duration: 0.25,
                          options: .defaultTransitionOption,
                          completion: nil)
    }
}

extension UIView.AnimationOptions {
    static let defaultTransitionOption : UIView.AnimationOptions = [.showHideTransitionViews,
                                                                    .transitionFlipFromLeft]
    static let defaultTransitionOption2 : UIView.AnimationOptions = [.showHideTransitionViews,
                                                                     .transitionFlipFromLeft]
}
