//
//  Utility.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 21/4/22.
//

import Foundation

class UtilityService{
    static let shared = UtilityService()
    
    var numberOfPracticeQuizzes = 0
    
    func getRandomRangeOfQuizzes(from quizArray: [QuizModel], startIndex: Int, endIndex: Int) -> [QuizModel]{
        return Array(quizArray[startIndex...endIndex])
    }
    
    func getRange(of quizArray: [QuizModel])-> (Int, Int){
        let totalAvailableQuiz = quizArray.count
        // get user selected range from settings
        guard let amountString = UserDefaults.standard.object(forKey: "NumberOfPracticeQuizzes") as? String, let diff = Int(amountString) else{
            if totalAvailableQuiz >= 20{
                return (0, 20)
            } else{
                return (0, totalAvailableQuiz - 1)
            }
            
        }
        let startIndex = Int.random(in: 0 ..< (totalAvailableQuiz - diff) )
        return (startIndex , startIndex + diff - 1 )
    }
    
    func getRandomQuizzes(from quizArray: [QuizModel]) -> [QuizModel]{
        let shuffledQuizzes = quizArray.shuffled()
        let (startIndex, endIndex) = self.getRange(of: shuffledQuizzes)
        return self.getRandomRangeOfQuizzes(from: quizArray, startIndex: startIndex, endIndex: endIndex)
        
    }
    
}
