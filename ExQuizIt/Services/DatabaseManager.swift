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
            RLMQuizModel(
                question: processText(for: $0.question),
                answer: processText(for: $0.correct_answer)
            )
        }
        
        writeToRealm {
            realm.add(quizEntries)
        }
    }
    
    // MARK: - GET methods
    
    func getQuizBy(id: String) -> RLMQuizModel? {
        realm.objects(RLMQuizModel.self).filter("id == %s", id).first
    }
    
    func getAllQuiz(isKnown: Bool? = nil) -> [Quiz] {
        switch isKnown {
        case .some(true):
            return Array(realm.objects(RLMQuizModel.self).filter("learningStatus == \(Constants.MaxLearningStatus)")).map { $0.asQuiz() }
        case .some(false):
            return Array(realm.objects(RLMQuizModel.self).filter("learningStatus != \(Constants.MaxLearningStatus)")).map { $0.asQuiz() }
        case .none:
            return Array(realm.objects(RLMQuizModel.self)).map { $0.asQuiz() }
        }
    }
    
    func saveQuiz(_ quiz: Quiz) {
        // Update
        if let id = quiz.id,
           let model = getQuizBy(id: id) {
            writeToRealm {
                model.update(with: quiz)
                realm.add(model)
            }
        }
        // Save new
        else {
            writeToRealm {
                let model = RLMQuizModel()
                model.update(with: quiz)
                realm.add(model)
            }
        }
    }
    
//    func saveQuiz(quiz: RLMQuizModel, question: String, answer: String) {
//        writeToRealm {
//            quiz.question = question
//            quiz.answer = answer
//            realm.add(quiz)
//        }
//    }
    
    func savePracticeSession(practiceSession: PracticeSession) {
        let practiceSessionModel = RLMPracticeSessionModel(practiceSession: practiceSession)
        
        writeToRealm {
            realm.add(practiceSessionModel)
        }
        
    }
    
//    func updateQuiz(quiz: Quiz, with learningStatus: Int) {
//        let quizToBeUpdated = getQuizBy(id: quiz.id ?? "") ?? RLMQuizModel()
//
//        writeToRealm {
//            quizToBeUpdated.learningStatus = learningStatus
////            quizToBeUpdated.isKnown = learningStatus >= Constants.MaxLearningStatus ? true : false
//
//            realm.add(quizToBeUpdated)
//        }
//    }
    
    func deleteQuiz(quiz: Quiz) {
        guard let quizToBeDeleted = getQuizBy(id: quiz.id ?? "")
        else { return }
        
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
