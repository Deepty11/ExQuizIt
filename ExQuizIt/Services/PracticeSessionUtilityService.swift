//
//  Utility.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 21/4/22.
//

import Foundation

enum PracticeQuizStatus: String {
    case learning = "Learning"
    case reviewing = "Reviewing"
    case mastered = "Mastered"
}

class PracticeSessionUtilityService {
    let databaseManager = DatabaseManager()
    
    func getPreferredNumberOfPracticeQuizzes() -> Int {
        let selectedNumber = UserDefaults.standard.integer(forKey: Strings.NumberOfPracticeQuizzes)
        
        if selectedNumber == 0 { return Constants.DefaultNumberOfPracticeQuizzes }
        
        return selectedNumber
    }
    
    func getRandomSlice(from quizArray: [Quiz], length: Int)-> [Quiz] {
        let totalAvailableQuiz = quizArray.count
        if totalAvailableQuiz == 0 {
            return []
        }
        
        let startIndex = Int.random(in: 0 ... (totalAvailableQuiz - length) )
        let endIndex = startIndex + length - 1
        return Array(quizArray[startIndex...endIndex])
    }
    
    func getRandomQuizzes(by category: String) -> [Quiz] {
        let shuffledQuizzes = databaseManager.getAllQuizzes(isKnown: false,
                                                            category: category).shuffled()
        let totalAvailableUnknownQuizzes = shuffledQuizzes.count
        let numberOfPracticeQuizzesSelected = getPreferredNumberOfPracticeQuizzes()
        
        if numberOfPracticeQuizzesSelected <= totalAvailableUnknownQuizzes {
            return getRandomSlice(from: shuffledQuizzes,
                                  length: numberOfPracticeQuizzesSelected)
        }
        
        var selectedQuizzes = shuffledQuizzes
        let requiredAmount = numberOfPracticeQuizzesSelected - selectedQuizzes.count
        let shuffledKnownQuizzes = databaseManager.getAllQuizzes(isKnown: true,
                                                                 category: category).shuffled()
        if requiredAmount > shuffledKnownQuizzes.count {
            selectedQuizzes += getRandomSlice(from: shuffledKnownQuizzes,
                                              length: shuffledKnownQuizzes.count)
        } else {
            selectedQuizzes += getRandomSlice(from: shuffledKnownQuizzes,
                                              length: requiredAmount)
        }
        
        
        return selectedQuizzes
    }
    
}
