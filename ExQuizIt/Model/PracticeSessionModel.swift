//
//  PracticeSessionModel.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 29/5/22.
//

import Foundation
import RealmSwift

class PracticeSessionModel: Object {
    @Persisted var id: String 
    @Persisted var startTime: String?
    @Persisted var endTime: String?
    @Persisted var quizList: List<QuizRecordModel>
    
    override init() {
        self.id = ""
        self.startTime = ""
        self.endTime = ""
        self.quizList = List<QuizRecordModel>()
    }
    
    init(id: String, startTime: String, endTime: String) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
    }
}

class QuizRecordModel: Object {
    @Persisted var id: String
    @Persisted var status: PracticeQuizStatus.RawValue?
    
    override init() {
        self.id = ""
        self.status = PracticeQuizStatus.learning.rawValue
    }
    
    init(id: String, status: String) {
        self.id = id
        self.status = status
    }
}
