//
//  AppState.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 12/4/22.
//

import Foundation
import UIKit


class AppState{
    static let shared = AppState()
    var answerViewDisplayed : [Bool] = []
    let transitionOption : UIView.AnimationOptions = [.showHideTransitionViews, .transitionFlipFromRight]
}
