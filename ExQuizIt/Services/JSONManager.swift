//
//  AppState.swift
//  NotesApp
//
//  Created by Rehnuma Reza on 11/4/22.
//

import Foundation

class JSONManager{
    static let shared = JSONManager()
    
    let quizJson = """
            [{
                "question" : "What does iOS stand for?",
                "answer" : "iPhone Operating System"
            },
            {
                "question" : "What Is A LLVM ?",
                "answer" : "Contains Both Compiler (swiftc And Objective C)"
            },
            {
                "question" : "What IDE is used for iOS development?",
                "answer" : "Xcode"
            },
            {
                "question" : "To create mutable object __ is used",
                "answer" : "var"
            },
            {
                "question" : "What Is Bundle In IOS",
                "answer" : "It Is Folder With .app Extension"
            },
            {
                "question" : "Application Running In Foreground But Currently Not Receiving Any Events .what Is The Current State Of Application?",
                "answer" : "Inactive State"
            },
            {
                "question" : "Meaning of IOS is -",
                "answer" : "Internetworking Operating System"
            },
            {
                "question" : "The most recent version of macOS is based on -",
                "answer" : "UNIX"
            },
            {
                "question" : "What is used to return multiple value from function in Swift?",
                "answer" : "Tuple"
            },
            {
                "question" : "In which year iOS was first written ?",
                "answer" : "1986"
            }]
"""
    
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
    
    func getAllQuizzesFromAPIs(completion: @escaping ([Quiz])->() ){
        var quizzes = [Quiz]()
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.getDataFrom(urlString: self.vehicleQuizURL) { vehicleQuizArray in
            quizzes.append(contentsOf: vehicleQuizArray)
        }
        dispatchGroup.leave()
        
        dispatchGroup.enter()
        self.getDataFrom(urlString: self.sportsQuizURL) { sportsQuizArray in
            quizzes.append(contentsOf: sportsQuizArray)
        }
        dispatchGroup.leave()
        
        dispatchGroup.enter()
        self.getDataFrom(urlString: self.computerQuizURL) { computerQuizArray in
            quizzes.append(contentsOf: computerQuizArray)
        }
        dispatchGroup.leave()
        
        dispatchGroup.notify(queue: .main) {
            completion(quizzes)
        }
        
        
    }
    
    
}


