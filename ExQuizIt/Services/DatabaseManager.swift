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
    
    func setLearningScale(of quiz: Quiz, with learningStatus: Int) {
        let quizToBeUpdated = getQuizBy(id: quiz.id ?? "")
        
        do {
            try realm.write {
                quizToBeUpdated.learningStatus = learningStatus
                quizToBeUpdated.isKnown = learningStatus >= Constants.MaxLearningStatus ? true : false
            
                realm.add(quizToBeUpdated)
                
                setPracticeQuizLearningStatusMap(quiz: quiz, with: learningStatus)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // to increment learningStatus and set isKnown accordingly
    func increaseLearningScale(of quiz: Quiz) {
        let learningStatus = min((quiz.learningStatus ?? Constants.MinLearningStatus) + 1, Constants.MaxLearningStatus)
        setLearningScale(of: quiz, with: learningStatus)
    }
    
    func getQuizBy(id: String) -> QuizModel {
        realm.objects(QuizModel.self).filter("id == %s", id).first ?? QuizModel()
    }
    
    func getAllQuiz() -> [Quiz] {
        Array(realm.objects(QuizModel.self)).map { $0.asQuiz() }
    }
    
//    func getRefreshedQuizzes(oldQuizzes: [QuizModel]) -> [QuizModel] {
//        realm.refresh()
//        return oldQuizzes.map(\.id)
//            .map {
//                getQuizBy(id: $0)
//            }
//    }
    
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
    
    func setPracticeQuizLearningStatusMap(quiz: Quiz, with value: Int) {
        switch value {
        case Constants.MaxLearningStatus:
            print("\(quiz.id ?? "") mastered")
            UtilityService.shared.practiceQuizLearningStatusMap[quiz.id ?? ""] = .mastered
        case Constants.MinLearningStatus:
            print("\(quiz.id ?? "") learning")
            UtilityService.shared.practiceQuizLearningStatusMap[quiz.id ?? ""] = .learning
        default:
            print("\(quiz.id ?? "") review")
            UtilityService.shared.practiceQuizLearningStatusMap[quiz.id ?? ""] = .reviewing
        }
    }
}
