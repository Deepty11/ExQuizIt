//
//  DatabaseManager.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 12/4/22.
//

import Foundation
import RealmSwift

class DatabaseManager {
    var realm = try! Realm()
    
    func storeJSONParsedQuiz(with quizzes: [Quiz]) {
        let quizEntries = quizzes.map {
            QuizModel(
                question: processText(for: $0.question),
                answer: processText(for: $0.correct_answer)
            )
        }
        
        writeToRealm {
            realm.add(quizEntries)
        }
    }
    
    // MARK: - GET methods
    
    func getQuizBy(id: String) -> QuizModel {
        realm.objects(QuizModel.self).filter("id == %s", id).first ?? QuizModel()
    }
    
    func getAllQuiz(isKnown: Bool? = nil) -> [Quiz] {
        switch isKnown {
        case .some(let known):
            return Array(realm.objects(QuizModel.self).filter("isKnown == \(known)")).map { $0.asQuiz() }
        case .none:
            return Array(realm.objects(QuizModel.self)).map { $0.asQuiz() }
        }
    }
    
//    func getAllUnknownQuizzes()-> [Quiz] {
//        Array(realm.objects(QuizModel.self).filter("isKnown == false")).map { $0.asQuiz() }
//    }
//
//    func getAllknownQuizzes()-> [Quiz] {
//        Array(realm.objects(QuizModel.self).filter("isKnown == true")).map { $0.asQuiz() }
//    }
    
    func saveQuiz(quiz: QuizModel, question: String, answer: String) {
        writeToRealm {
            quiz.question = question
            quiz.answer = answer
            realm.add(quiz)
        }
    }
    
    func savePracticeSession(practiceSession: PracticeSession) {
        let practiceSessionModel = RLMPracticeSessionModel(practiceSession: practiceSession)
        
        writeToRealm {
            realm.add(practiceSessionModel)
        }
        
    }
    
    func updateQuiz(quiz: Quiz, with learningStatus: Int) {
        let quizToBeUpdated = getQuizBy(id: quiz.id ?? "")
        
        writeToRealm {
            quizToBeUpdated.learningStatus = learningStatus
            quizToBeUpdated.isKnown = learningStatus >= Constants.MaxLearningStatus ? true : false
        
            realm.add(quizToBeUpdated)
        }
    }
    
    func deleteQuiz(quiz: Quiz) {
        let quizToBeDeleted = getQuizBy(id: quiz.id ?? "")
        writeToRealm {
            realm.delete(quizToBeDeleted)
            print("deleted!!")
        }
    }
    
    // MARK: - Private Utils
    
    private func processText(for text: String) -> String {
        return text
            .replacingOccurrences(of: "&#039;", with: "'")
            .replacingOccurrences(of: "&quot;", with: "\"")
    }
    
    private func writeToRealm(_ writeBlock: () -> ()) {
        do {
            try realm.write {
                writeBlock()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
