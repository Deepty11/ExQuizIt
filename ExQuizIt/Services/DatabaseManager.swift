//
//  DatabaseManager.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 12/4/22.
//

import Foundation
import RealmSwift

class DatabaseManager{
    static let shared = DatabaseManager()
    var realm = try! Realm()
    
    func storeJSONParsedQuiz(with quizzes: [Quiz]){
        var quizEntries = [QuizModel]()
        for quiz in quizzes{
            let quizModel = QuizModel()
            quizModel.question = quiz.question.replacingOccurrences(of: "&#039;", with: "'").replacingOccurrences(of: "&quot;", with: "\"")
            quizModel.answer = quiz.correct_answer.replacingOccurrences(of: "&#039;", with: "'").replacingOccurrences(of: "&quot;", with: "\"")
            quizModel.isKnown = false
            quizEntries.append(quizModel)
        }
        do{
            try realm.write{
                realm.add(quizEntries)
            }
        } catch{
            print(error.localizedDescription)
        }
    }
    
    func updateLearningStatus(with status: Bool, of quiz: QuizModel){
        let quizTobeUpdated = realm.objects(QuizModel.self).filter("question == %@", quiz.question ?? "")[0]
        do{
            try realm.write{
                quizTobeUpdated.isKnown = status
                // if status is true, set learningStatus to 5 and 0 otherwise
                quizTobeUpdated.learningStatus = status ? 5 : 0
                realm.add(quizTobeUpdated)
                quizTobeUpdated.isKnown ? print("learnt") : print("learning")
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // to increment learningStatus and set isKnown accordingly 
    func updateLearningScale(with setlearningScale: Bool, of quiz: QuizModel){
        let quizTobeUpdated = realm.objects(QuizModel.self).filter("question == %@", quiz.question ?? "")[0]
        do{
            try realm.write{
                
                if setlearningScale == true{
                    quizTobeUpdated.learningStatus = quizTobeUpdated.learningStatus < 5 ? 5 : 0 // increase learningStatus by 1 if not already set to 5 
                } else{
                    quizTobeUpdated.learningStatus = 0
                }
                quizTobeUpdated.isKnown = quizTobeUpdated.learningStatus >= 5 ? true : false
                quizTobeUpdated.isKnown ? print("learnt") : print("learning")
                realm.add(quizTobeUpdated)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func getAllQuiz()-> [QuizModel]{
        return Array(realm.objects(QuizModel.self))
    }
    
    func getQuizByQuestion(question: String) -> QuizModel{
        return realm.objects(QuizModel.self).filter("question == %@", question)[0]
    }
    
    func getAllUnknownQuizzes()-> [QuizModel]{
        return Array(realm.objects(QuizModel.self).filter("isKnown == false"))
    }
    
    
    func getAllknownQuizzes()-> [QuizModel]{
        return Array(realm.objects(QuizModel.self).filter("isKnown == true"))
    }
    func saveQuizToDatabase(quiz: QuizModel,
                            question: String,
                            answer: String){
        do{
            try realm.write {
                quiz.question = question
                quiz.answer = answer
                quiz.isKnown = false
                quiz.learningStatus = 0
                realm.add(quiz)
            }
           
        } catch{
            print(error.localizedDescription)
        }
    }
    
    func deleteQuizFromDatabase(quiz: QuizModel){
        do{
            try realm.write {
                realm.delete(quiz)
                print("deleted!!")
            }
        }catch{
            print(error.localizedDescription)
        }
    }
}
