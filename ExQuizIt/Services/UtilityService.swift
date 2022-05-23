//
//  Utility.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 21/4/22.
//

import Foundation

enum PracticeQuizStatus {
    case learning
    case reviewing
    case mastered
}

class UtilityService {
    static let shared = UtilityService()
    
    var numberOfPracticeQuizzes = 0
    final let defaultNumberOfPracticeQuestions = 20.0
    var practiceQuizLearningStatusArray: [PracticeQuizStatus] = []
    
    func getPreferredNumberOfPracticeQuizzes() -> Int {
        return UserDefaults.standard.integer(forKey: Strings.NumberOfPracticeQuizzes)
    }
    
    func getRandomSlice(from quizArray: [QuizModel], length: Int)-> [QuizModel] {
        let totalAvailableQuiz = quizArray.count
        let startIndex = Int.random(in: 0 ... (totalAvailableQuiz - length) )
        let endIndex = startIndex + length - 1
        return Array(quizArray[startIndex...endIndex])
    }
    
    func getRandomQuizzes(from quizArray: [QuizModel]) -> [QuizModel] {
        let shuffledQuizzes = quizArray.shuffled()
        let totalAvailableUnknownQuiz = quizArray.count
        let numberOfPracticeQuizzesSelected = getPreferredNumberOfPracticeQuizzes()
        
        if numberOfPracticeQuizzesSelected <= totalAvailableUnknownQuiz {
            return self.getRandomSlice(from: shuffledQuizzes,
                                       length: numberOfPracticeQuizzesSelected)
        }
        
        var selectedQuizzes = shuffledQuizzes
        let requiredAmount = numberOfPracticeQuizzesSelected - selectedQuizzes.count
        let shuffledKnownQuizzes = DatabaseManager.shared.getAllknownQuizzes().shuffled()
        selectedQuizzes += getRandomSlice(from: shuffledKnownQuizzes,
                                          length: requiredAmount)
        
        return selectedQuizzes
    }
    
}
