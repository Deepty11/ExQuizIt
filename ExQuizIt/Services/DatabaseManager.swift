//
//  DatabaseManager.swift
//  NotesApp
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
    
    func saveQuizToDatabase(question: String, answer: String){
        do{
            try realm.write {
                let quiz = QuizModel()
                quiz.question = question
                quiz.answer = answer
                quiz.isKnown = false
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
