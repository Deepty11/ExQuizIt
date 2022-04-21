//
//  Utility.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 21/4/22.
//

import Foundation

class UtilityService{
    static let shared = UtilityService()
    
    func getRandomRangeOfQuizzes(from quizArray: [QuizModel], startIndex: Int, endIndex: Int) -> [QuizModel]{
        return Array(quizArray[startIndex...endIndex])
    }
    
    func getRange(of quizArray: [QuizModel])-> (Int, Int){
        let totalAvailableQuiz = quizArray.count
        let startIndex = Int.random(in: 0 ..< totalAvailableQuiz/2 )
        let diff = Int.random(in: 8 ... 30 ) //
        
//        if num1 < num2{
//            return (num1, num2)
//        } else if num1 > num2{
//            return (num2, num1)
//        }
        return (startIndex , startIndex + diff )
    }
    
    func getRandomQuizzes(from quizArray: [QuizModel]) -> [QuizModel]{
        let shuffledQuizzes = quizArray.shuffled()
        let (startIndex, endIndex) = self.getRange(of: shuffledQuizzes)
        return self.getRandomRangeOfQuizzes(from: quizArray, startIndex: startIndex, endIndex: endIndex)
        
    }
    
    func getHTMLNotationsInString(textString: String){
        let range = NSRange(location: 0, length: textString.utf8.count)
        let regex = try! NSRegularExpression(pattern: "^&.*;$")
        let matches = regex.matches(in: textString, range: range)
    }
}
