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
    
    func getQuizBy(id: String) -> QuizModel {
        realm.objects(QuizModel.self).filter("id == %s", id).first ?? QuizModel()
    }
    
    func getAllQuiz() -> [Quiz] {
        Array(realm.objects(QuizModel.self)).map { $0.asQuiz() }
    }
    
    func getAllUnknownQuizzes()-> [Quiz] {
        Array(realm.objects(QuizModel.self).filter("isKnown == false")).map { $0.asQuiz() }
    }
    
    func getAllknownQuizzes()-> [Quiz] {
        Array(realm.objects(QuizModel.self).filter("isKnown == true")).map { $0.asQuiz() }
    }
    
    func saveQuiz(quiz: QuizModel, question: String, answer: String) {
        do  {
            try realm.write {
                quiz.question = question
                quiz.answer = answer
                realm.add(quiz)
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func savePracticeSession(practiceSession: PracticeSession) {
        let quizRecordModels = practiceSession.quizRecords.map { QuizRecordModel(id: $0.id,
                                                                                 status: $0.status) }
        let practiceSessionModel = PracticeSessionModel(id: practiceSession.id,
                                                        startTime: practiceSession.startTime,
                                                        endTime: practiceSession.endTime)
        practiceSessionModel.quizList.append(objectsIn: quizRecordModels)
        
        do  {
            try realm.write {
                realm.add(practiceSessionModel)
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateQuiz(quiz: Quiz, with learningStatus: Int) {
        let quizToBeUpdated = getQuizBy(id: quiz.id ?? "")
        
        do {
            try realm.write {
                quizToBeUpdated.learningStatus = learningStatus
                quizToBeUpdated.isKnown = learningStatus >= Constants.MaxLearningStatus ? true : false
            
                realm.add(quizToBeUpdated)
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteQuiz(quiz: Quiz) {
        let quizToBeDeleted = getQuizBy(id: quiz.id ?? "")
        
        do {
            try realm.write {
                realm.delete(quizToBeDeleted)
                print("deleted!!")
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
