//
//  Utility.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 21/4/22.
//

import Foundation

enum PracticeQuizStatus{
    case mastered
    case reviewing
    case learning
}

class UtilityService{
    static let shared = UtilityService()
    
    var numberOfPracticeQuizzes = 0
    var practiceQuizLearningStatusArray: [PracticeQuizStatus] = []
    
    func getRandomRangeOfQuizzes(from quizArray: [QuizModel], startIndex: Int, endIndex: Int) -> [QuizModel]{
        return Array(quizArray[startIndex...endIndex])
    }
    
    func getNumberOfPracticeQuizzesSelected() -> Int{
        if  let amountString = UserDefaults.standard.object(forKey: "NumberOfPracticeQuizzes") as? String,
            let diff = Int(amountString){
            return diff
        }
        return 20
    }
    
    func getStartAndEndIndex(for quizArray: [QuizModel], range: Int)-> (Int, Int){
        let totalAvailableQuiz = quizArray.count
        let startIndex = Int.random(in: 0 ..< (totalAvailableQuiz - range) )
        return (startIndex , startIndex + range - 1 )
    }
    
    func getRandomQuizzes(from quizArray: [QuizModel]) -> [QuizModel]{
        let shuffledQuizzes = quizArray.shuffled()
        let totalAvailableUnknownQuiz = quizArray.count
        let numberOfPracticeQuizzesSelected = getNumberOfPracticeQuizzesSelected()
        
        if numberOfPracticeQuizzesSelected < totalAvailableUnknownQuiz{
            let (startIndex, endIndex) = self.getStartAndEndIndex(for: shuffledQuizzes,
                                                                  range: numberOfPracticeQuizzesSelected)
            return self.getRandomRangeOfQuizzes(from: quizArray,
                                                startIndex: startIndex,
                                                endIndex: endIndex)
            
        } else if numberOfPracticeQuizzesSelected == totalAvailableUnknownQuiz{
            return getRandomRangeOfQuizzes(from: quizArray,
                                           startIndex: 0,
                                           endIndex: numberOfPracticeQuizzesSelected - 1)
            
        } else{
            let requiredAmount = numberOfPracticeQuizzesSelected - totalAvailableUnknownQuiz
            let shuffledKnownQuizzes = DatabaseManager.shared.getAllknownQuizzes().shuffled()
            let (startIndex, endIndex) = self.getStartAndEndIndex(for: shuffledKnownQuizzes,
                                                                  range: requiredAmount)
            return shuffledQuizzes + self.getRandomRangeOfQuizzes(from: shuffledKnownQuizzes,
                                                                  startIndex: startIndex,
                                                                  endIndex: endIndex)
            
        }
        
    }
    
}
