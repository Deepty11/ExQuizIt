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
    
    func storeCategories() {
        let categoryNames = getAllCategoryNamesFromQuizzes()
        var categories: [RLMCategoryModel] = []
        let _ = categoryNames.map {
            categories.append(RLMCategoryModel(category: Category(name: $0)))
        }
        
        writeToRealm {
            realm.add(categories)
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
    
    func getAllQuizCategories(by categoryName: String? = nil) -> [Category] {
        guard let categoryName = categoryName else {
            return Array(realm.objects(RLMCategoryModel.self).map { $0.asCategory() })
        }
        
        return Array(realm.objects(RLMCategoryModel.self)
            .filter("name == %s", categoryName)
            .map { $0.asCategory() })
    }
    
    func getCategory(by id: String) -> RLMCategoryModel? {
        return realm.objects(RLMCategoryModel.self).filter("id == %s", id).first
    }
    
    func getAllQuizzesBy(category: String) -> [RLMQuizModel] {
        return realm.objects(RLMQuizModel.self).filter("category == %s", category).asArray()
    }
    
    func getFilteredQuizzes(by searchText: String, of category: String) -> [Quiz]{
        getAllQuizzesBy(category: category).map { $0.asQuiz() }.filter({
            let searchableText = $0.question + $0.correct_answer
            
            return searchableText.range(of: searchText,
                                        options: .caseInsensitive,
                                        range: nil ,
                                        locale: nil) != nil
            
        })
    }
    
    func getFilteredCategories(by searchText: String) -> [Category]{
        getAllQuizCategories().filter {
            return $0.name?.range(of: searchText,
                            options: .caseInsensitive,
                            range: nil ,
                            locale: nil) != nil
        }
    }

    
    func filteredQuizzes(by searchText: String,
                       in quizzes: [Quiz]) -> [Quiz] {
        
        quizzes.filter({
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
    
    func getAllCategoryNamesFromQuizzes() -> Set<String>{
        var categoriesSet: Set<String> = []
        let _ = getAllQuizzes().map {
            categoriesSet.insert($0.category ?? "" )
        }
        
        return categoriesSet
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
    
    func saveCategory(_ category: Category) {
        // Update
        if let id = category.id,
           let model = getCategory(by: id) {
            let quizzes = getAllQuizzesBy(category: model.name)
            
            writeToRealm {
                model.update(with: category)
                
                for quiz in quizzes {
                    quiz.category = category.name
                }
                
                realm.add(model)
                realm.add(quizzes)
            }
        }
        // Save new
        else {
            writeToRealm {
                let model = RLMCategoryModel()
                model.update(with: category)
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
    
    func deleteQuizzes(by category: String) {
        let quizzes = getAllQuizzesBy(category: category)
        
        writeToRealm {
            realm.delete(quizzes)
            print("deleted!!")
        }
    }
    
    func deleteCategory(by id: String) {
        guard let category = getCategory(by: id) else { return }
        
        deleteQuizzes(by: category.name)
        
        writeToRealm {
            realm.delete(category)
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
