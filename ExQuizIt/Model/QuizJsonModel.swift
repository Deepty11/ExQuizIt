//
//  QuizModel.swift
//  NotesApp
//
//  Created by Rehnuma Reza on 12/4/22.
//

import Foundation

struct Quizzes: Decodable{
    var results: [Quiz]
    
}

struct Quiz: Decodable{
    var category: String
    var difficulty: String
    var question: String
    var correct_answer: String
}
