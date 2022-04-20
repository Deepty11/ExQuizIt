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
            quizModel.question = quiz.question
            quizModel.answer = quiz.correct_answer
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
}
