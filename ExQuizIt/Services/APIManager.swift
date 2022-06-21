//
//  AppState.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 11/4/22.
//

import Foundation

class APIManager {
    static let baseURL = "https://opentdb.com/api.php"
    
    static let computerQuizURL = "?amount=50&category=18"
    static let matheMaticsQuizURL = "?amount=50&category=19"
    static let sportsQuizURL = "?amount=50&category=21"
    static let vehicleQuizURL = "?amount=50&category=28"
    
    static let quizCategories = [computerQuizURL,
                                 matheMaticsQuizURL,
                                 sportsQuizURL,
                                 vehicleQuizURL]
    
    var quizzes: [Quiz] = []
    
    func getDataFrom(urlString: String,
                     baseURLString: String = baseURL,
                     completion: @escaping ([Quiz])-> Void) {
        if let url = URL(string: baseURLString + urlString) {
            let session = URLSession.shared
            let urlRequest = URLRequest(url: url)
            var quizzes = [Quiz]()
            
            session.dataTask(with: urlRequest) { data, response, error in
                guard error == nil else { return }
                
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
    
    func getQuizzesFromAPI(completion: @escaping ([Quiz])->() ) {
        let dispatchGroup = DispatchGroup()
        
        for category in Self.quizCategories {
            fetchQuizzes(from: category, dispatchGroup: dispatchGroup)
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            completion(self.quizzes)
        } 
    }
    
    func fetchQuizzes(from urlString: String, dispatchGroup: DispatchGroup ){
        dispatchGroup.enter()
        
        getDataFrom(urlString: urlString) { [weak self] results in
            self?.quizzes.append(contentsOf: results)
            dispatchGroup.leave()
            
        }
    }
    
}


