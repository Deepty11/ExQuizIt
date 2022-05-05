//
//  QuizModel.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 12/4/22.
//

import Foundation
import RealmSwift

class QuizModel: Object{
    @Persisted var question: String?
    @Persisted var answer: String?
    @Persisted var isKnown: Bool
    @Persisted var learningStatus: Int
}
