//
//  AppState.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 11/4/22.
//

import Foundation

class JSONManager{
    static let shared = JSONManager()
    let vehicleQuizURL = "https://opentdb.com/api.php?amount=50&category=28"
    let sportsQuizURL = "https://opentdb.com/api.php?amount=50&category=21"
    let computerQuizURL = "https://opentdb.com/api.php?amount=30&category=18"
    
    func getDataFrom(urlString: String, completion: @escaping ([Quiz])-> Void){
        if let url = URL(string: urlString){
            let session = URLSession.shared
            let urlRequest = URLRequest(url: url)
            var quizzes = [Quiz]()
            session.dataTask(with: urlRequest) { data, response, error in
                guard error == nil else{
                    return
                }
                if let data = data{
                    quizzes = self.parseJsonFrom(data: data)
                    completion(quizzes)
                    
                }
            }.resume()
        }
    }
    
    func parseJsonFrom(data: Data) -> [Quiz]{
        var quizJsonObjects: [Quiz]
        do{
            let jsonObject = try JSONDecoder().decode(Quizzes.self, from: data)
            quizJsonObjects = jsonObject.results
            return quizJsonObjects
            
        } catch{
            print(error.localizedDescription)
        }
       return []
    }
    
    func getAllQuizzesFromAPIsAndCachingToRealm(completion: @escaping ([Quiz])->() ){
        let quizzes = [Quiz]()
        let dispatchGroup = DispatchGroup()
        
        // fetching and storing vehicles Quizzes
        dispatchGroup.enter()
        self.getDataFrom(urlString: self.vehicleQuizURL) { vehicleQuizArray in
            DispatchQueue.main.async {
                DatabaseManager.shared.storeJSONParsedQuiz(with: vehicleQuizArray)
            }
            dispatchGroup.leave()
        }
        
        // fetching and storing sports Quizzes
        dispatchGroup.enter()
        self.getDataFrom(urlString: self.sportsQuizURL) { sportsQuizArray in
            DispatchQueue.main.async {
                DatabaseManager.shared.storeJSONParsedQuiz(with: sportsQuizArray)
            }
            dispatchGroup.leave()
        }
        
        // fetching and storing computer Quizzes
        dispatchGroup.enter()
        self.getDataFrom(urlString: self.computerQuizURL) { computerQuizArray in
            DispatchQueue.main.async {
                DatabaseManager.shared.storeJSONParsedQuiz(with: computerQuizArray)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(quizzes)
        }
        
    }
    
}


