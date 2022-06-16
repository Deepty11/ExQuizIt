//
//  AppState.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 11/4/22.
//

import Foundation

class APIManager {
    static let baseURL = "https://opentdb.com/api.php"
    
    static let vehicleQuizURL = "?amount=50&category=28"
    static let sportsQuizURL = "?amount=50&category=21"
    static let computerQuizURL = "?amount=30&category=18"
    
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
        
        fetchAndStoreData(from: Self.vehicleQuizURL, dispatchGroup: dispatchGroup)
        fetchAndStoreData(from: Self.sportsQuizURL, dispatchGroup: dispatchGroup)
        fetchAndStoreData(from: Self.computerQuizURL, dispatchGroup: dispatchGroup)
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            completion(self.quizzes)
        } 
    }
    
    func fetchAndStoreData(from urlString: String, dispatchGroup: DispatchGroup ){
        dispatchGroup.enter()
        
        getDataFrom(urlString: urlString) { [weak self] results in
            self?.quizzes.append(contentsOf: results)
            dispatchGroup.leave()
            
        }
    }
    
}


