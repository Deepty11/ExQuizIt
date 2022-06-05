//
//  QuizJsonModel.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 12/4/22.
//

import Foundation

struct Quizzes: Decodable {
    var results: [Quiz]
}

struct Quiz: Decodable {
    var id: String?
    var category: String?
    var difficulty: String?
    var question: String
    var correct_answer: String
    var learningStatus: Int? = Constants.MinLearningStatus
    var numberOfTimesAppeared: Int? = 0
    var latestTimeAppeared: String? = "---"
    
    var isKnown: Bool {
        learningStatus ?? Constants.MinLearningStatus >= Constants.MaxLearningStatus ? true : false
    }
    
}
