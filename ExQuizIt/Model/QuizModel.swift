//
//  QuizModel.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 12/4/22.
//

import Foundation
import RealmSwift

class QuizModel: Object {
    @Persisted var id: String = UUID().uuidString
    @Persisted var question: String?
    @Persisted var answer: String?
    @Persisted var isKnown: Bool = false
    @Persisted var learningStatus: Int = Constants.MinLearningStatus
}

extension QuizModel {
    func asQuiz() -> Quiz {
        Quiz(id: id, question: question ?? "", correct_answer: answer ?? "", isKnown: isKnown , learningStatus: learningStatus)
    }
}
