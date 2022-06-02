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
    
    func getAllQuizzes(isKnown: Bool? = nil) -> [Quiz] {
        switch isKnown {
        case .some(true):
            return Array(realm.objects(RLMQuizModel.self).filter("learningStatus == \(Constants.MaxLearningStatus)")).map { $0.asQuiz() }
        case .some(false):
            return Array(realm.objects(RLMQuizModel.self).filter("learningStatus != \(Constants.MaxLearningStatus)")).map { $0.asQuiz() }
        case .none:
            return Array(realm.objects(RLMQuizModel.self)).map { $0.asQuiz() }
        }
    }
    
    func getAllPracticeSessions() -> [PracticeSession] {
        Array(realm.objects(RLMPracticeSessionModel.self)).map { $0.asPracticeSession() }
    }
    
    func getPracticeSessionBy(id: String) -> RLMPracticeSessionModel? {
        realm.objects(RLMPracticeSessionModel.self).filter("id == %s", id).first
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
    
    func savePracticeSession(practiceSession: PracticeSession) {
        let practiceSessionModel = RLMPracticeSessionModel(practiceSession: practiceSession)
        
        writeToRealm {
            realm.add(practiceSessionModel)
        }
        
    }
    
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
