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
    
    func storeQuizzes(_ quizzes: [Quiz]) {
        let quizEntries = quizzes.map {
            RLMQuizModel(
                category: processText(for: $0.category ?? ""),
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
    
    func getAllQuizCategories() -> [String] {
        var categoriesSet: Set<String> = []
        let _ = getAllQuizzes().map {
            categoriesSet.insert($0.category ?? "" )
        }
        return Array(categoriesSet)
    }
    
    func getAllQuizzesBy(category: String) -> [Quiz] {
        return Array(realm.objects(RLMQuizModel.self)
            .filter("category == %s", category))
        .map { $0.asQuiz() }
    }
    
    func filterQuizzes(with searchText: String) -> [Quiz]{
        getAllQuizzes().filter({
            let searchableText = $0.question + $0.correct_answer
            return searchableText.range(of: searchText,
                                        options: .caseInsensitive,
                                        range: nil ,
                                        locale: nil) != nil
            
        })
    }
    
    func getAllPracticeSessions() -> [PracticeSession] {
        Array(realm.objects(RLMPracticeSessionModel.self)).map { $0.asPracticeSession() }
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
            .replacingOccurrences(of: "&ldquo;", with: "\"")
            .replacingOccurrences(of: "&rdquo;", with: "\"")
            .replacingOccurrences(of: "Science: ", with: "")
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
