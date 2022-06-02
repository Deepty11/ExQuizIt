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
        let selectedValue = UserDefaults.standard.integer(forKey: Strings.NumberOfPracticeQuizzes)
        
        if selectedValue == 0 {
            return Constants.DefaultNumberOfPracticeQuestions
        }
        
        return selectedValue
    }
    
    func getRandomSlice(from quizArray: [Quiz], length: Int)-> [Quiz] {
        let totalAvailableQuiz = quizArray.count
        let startIndex = Int.random(in: 0 ... (totalAvailableQuiz - length) )
        let endIndex = startIndex + length - 1
        return Array(quizArray[startIndex...endIndex])
    }
    
    func getRandomQuizzes(from quizArray: [Quiz]) -> [Quiz] {
        let shuffledQuizzes = quizArray.shuffled()
        let totalAvailableUnknownQuiz = quizArray.count
        let numberOfPracticeQuizzesSelected = getPreferredNumberOfPracticeQuizzes()
        
        if numberOfPracticeQuizzesSelected <= totalAvailableUnknownQuiz {
            return getRandomSlice(from: shuffledQuizzes,
                                  length: numberOfPracticeQuizzesSelected)
        }
        
        var selectedQuizzes = shuffledQuizzes
        let requiredAmount = numberOfPracticeQuizzesSelected - selectedQuizzes.count
        let shuffledKnownQuizzes = databaseManager.getAllQuizzes(isKnown: true).shuffled()
        selectedQuizzes += getRandomSlice(from: shuffledKnownQuizzes,
                                          length: requiredAmount)
        
        return selectedQuizzes
    }
    
}
