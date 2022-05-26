//
//  AppState.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 11/4/22.
//

import Foundation

class JSONManager {
    static let shared = JSONManager()
    
    static let baseURL = "https://opentdb.com/api.php"
    
    static let vehicleQuizURL = "?amount=50&category=28"
    static let sportsQuizURL = "?amount=50&category=21"
    static let computerQuizURL = "?amount=30&category=18"
    
    func getDataFrom(urlString: String, baseURLString: String = baseURL, completion: @escaping ([Quiz])-> Void) {
        if let url = URL(string: baseURLString + urlString) {
            let session = URLSession.shared
            let urlRequest = URLRequest(url: url)
            var quizzes = [Quiz]()
            
            session.dataTask(with: urlRequest) { data, response, error in
                guard error == nil else {
                    return
                }
                
                if let data = data {
                    quizzes = self.parseJsonFrom(data: data)
                    completion(quizzes)
                }
            }.resume()
        }
    }
    
    func parseJsonFrom(data: Data) -> [Quiz] {
        var quizJsonObjects: [Quiz] = []
        
        do {
            let jsonObject = try JSONDecoder().decode(Quizzes.self, from: data)
            quizJsonObjects = jsonObject.results
        } catch {
            print(error.localizedDescription)
        }
        
        return quizJsonObjects
    }
    
    func getAllQuizzesFromAPIsAndCachingToRealm(completion: @escaping ()->() ) {
        let dispatchGroup = DispatchGroup()
        
        // fetching and storing vehicles Quizzes
        dispatchGroup.enter()
        self.getDataFrom(urlString: Self.vehicleQuizURL) { vehicleQuizArray in
            DispatchQueue.main.async {
                DatabaseManager.shared.storeJSONParsedQuiz(with: vehicleQuizArray)
            }
            
            dispatchGroup.leave()
        }
        
        // fetching and storing sports Quizzes
        dispatchGroup.enter()
        self.getDataFrom(urlString: Self.sportsQuizURL) { sportsQuizArray in
            DispatchQueue.main.async {
                DatabaseManager.shared.storeJSONParsedQuiz(with: sportsQuizArray)
            }
            
            dispatchGroup.leave()
        }
        
        // fetching and storing computer Quizzes
        dispatchGroup.enter()
        self.getDataFrom(urlString: Self.computerQuizURL) { computerQuizArray in
            DispatchQueue.main.async {
                DatabaseManager.shared.storeJSONParsedQuiz(with: computerQuizArray)
            }
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion()
        }
        
    }
    
}


