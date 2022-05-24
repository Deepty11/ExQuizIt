//
//  DatabaseManager.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 12/4/22.
//

import Foundation
import RealmSwift

class DatabaseManager {
    static let shared = DatabaseManager()
    var realm = try! Realm()
    
    func storeJSONParsedQuiz(with quizzes: [Quiz]) {
        var quizEntries = [QuizModel]()
        
        for quiz in quizzes {
            let quizModel = QuizModel()
            
            quizModel.question = processText(for: quiz.question)
            quizModel.answer = processText(for: quiz.correct_answer)
            
            quizEntries.append(quizModel)
        }
        
        do{
            try realm.write {
                realm.add(quizEntries)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func processText(for text: String) -> String {
        return text
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&quot;", with: "\"")
    }
    
    func updateLearningStatus(of quiz: QuizModel, with status: Bool) {
        let quizToBeUpdated = realm.objects(QuizModel.self).filter("question == %@", quiz.question ?? "")[0]
        
        do{
            try realm.write{
                quizToBeUpdated.isKnown = status
                // if status is true, set learningStatus to 5 and 0 otherwise
                quizToBeUpdated.learningStatus = status
                ? Constants.MaxValueForLearningStatus
                : Constants.MinValueForLearningStatus
                UtilityService.shared.practiceQuizLearningStatusArray.append(status
                                                                             ? PracticeQuizStatus.mastered
                                                                             : PracticeQuizStatus.learning)
                realm.add(quizToBeUpdated)
                quizToBeUpdated.isKnown ? print("learnt") : print("learning")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // to increment learningStatus and set isKnown accordingly
    func updateLearningScale(of quiz: QuizModel, with setlearningScale: Bool){
        let quizTobeUpdated = DatabaseManager.shared.getQuizByQuestion(question: quiz.question ?? "")//realm.objects(QuizModel.self).filter("question == %@", quiz.question ?? "").first
        do{
            try realm.write{
                quizTobeUpdated.learningStatus = quizTobeUpdated.learningStatus < Constants.MaxValueForLearningStatus
                ? (quizTobeUpdated.learningStatus + 1)
                : Constants.MaxValueForLearningStatus
                quizTobeUpdated.isKnown = quizTobeUpdated.learningStatus >= Constants.MaxValueForLearningStatus
                ? true
                : false
                
                if quizTobeUpdated.learningStatus >= Constants.MaxValueForLearningStatus {
                    print("learnt")
                    UtilityService.shared.practiceQuizLearningStatusArray.append(.mastered)
                } else if quizTobeUpdated.learningStatus < Constants.MaxValueForLearningStatus
                            && quizTobeUpdated.learningStatus > Constants.MinValueForLearningStatus {
                    print("review")
                    UtilityService.shared.practiceQuizLearningStatusArray.append(.reviewing)
                } else {
                    print("learning")
                    UtilityService.shared.practiceQuizLearningStatusArray.append(.learning)
                }
                
                realm.add(quizTobeUpdated)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getAllQuiz() -> [QuizModel]{
        return Array(realm.objects(QuizModel.self))
    }
    
    func getQuizByQuestion(question: String) -> QuizModel{
        return realm.objects(QuizModel.self).filter("question == %@", question).first ?? QuizModel()
    }
    
    func getAllUnknownQuizzes()-> [QuizModel]{
        return Array(realm.objects(QuizModel.self).filter("isKnown == false"))
    }
    
    func getAllknownQuizzes()-> [QuizModel]{
        return Array(realm.objects(QuizModel.self).filter("isKnown == true"))
    }
    
    func saveQuiz(quiz: QuizModel, question: String, answer: String) {
        do{
            try realm.write {
                quiz.question = question
                quiz.answer = answer
                realm.add(quiz)
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteQuiz(quiz: QuizModel) {
        do{
            try realm.write {
                realm.delete(quiz)
                print("deleted!!")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
