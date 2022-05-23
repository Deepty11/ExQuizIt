//
//  AppState.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 12/4/22.
//

import Foundation
import UIKit


struct Constants {
    static let MaxValueForLearningStatus = 5
    static let MinValueForLearningStatus = 0
    static let DefaultNumberOfPracticeQuestions = 20
}

struct Strings {
    static let NumberOfPracticeQuizzes = "NumberOfPracticeQuizzes"
}

extension UIView.AnimationOptions {
    static let defaultTransitionOption : UIView.AnimationOptions = [.showHideTransitionViews,
                                                                    .transitionFlipFromRight]
}
