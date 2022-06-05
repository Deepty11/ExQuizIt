//
//  QuizModel.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 12/4/22.
//

import Foundation
import RealmSwift

class RLMQuizModel: Object {
    @Persisted var id: String = UUID().uuidString
    @Persisted var question: String?
    @Persisted var answer: String?
    @Persisted var learningStatus: Int = Constants.MinLearningStatus
    @Persisted var numberOfTimesAppeared: Int = 0
    @Persisted var latestTimeAppeared: String? = "---"
    
    var isKnown: Bool {
        learningStatus >= Constants.MaxLearningStatus ? true : false
    }
}

extension RLMQuizModel {
    convenience init(question: String, answer: String) {
        self.init()
        self.question = question
        self.answer = answer
    }
    
    func asQuiz() -> Quiz {
        Quiz(id: id, question: question ?? "",
             correct_answer: answer ?? "",
             learningStatus: learningStatus,
             numberOfTimesAppeared: numberOfTimesAppeared,
             latestTimeAppeared: latestTimeAppeared)
    }
    
    func update(with quiz: Quiz) {
        question = quiz.question
        answer = quiz.correct_answer
        learningStatus = quiz.learningStatus ?? Constants.MinLearningStatus
        numberOfTimesAppeared = quiz.numberOfTimesAppeared ?? 0
        latestTimeAppeared = quiz.latestTimeAppeared
    }
}
