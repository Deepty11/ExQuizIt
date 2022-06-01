//
//  PracticeSessionModel.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 29/5/22.
//

import Foundation
import RealmSwift

class RLMPracticeSessionModel: Object {
    @Persisted var id: String 
    @Persisted var startTime: String?
    @Persisted var endTime: String?
    @Persisted var quizList: List<RLMQuizRecordModel>
    
    override init() {
    }
    
    init(id: String = "",
         startTime: String = "",
         endTime: String = "",
         quizList: List<RLMQuizRecordModel> = .init()) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.quizList = quizList
    }
}

class RLMQuizRecordModel: Object {
    @Persisted var id: String
    @Persisted var status: PracticeQuizStatus.RawValue?
    
    override init() {}
    
    init(id: String = "", status: String = PracticeQuizStatus.learning.rawValue) {
        self.id = id
        self.status = status
    }
}

extension RLMPracticeSessionModel {
    convenience init(practiceSession: PracticeSession) {
        self.init(
            id: practiceSession.id,
            startTime: practiceSession.startTime,
            endTime: practiceSession.endTime,
            quizList: practiceSession.quizRecords.map(RLMQuizRecordModel.init).asList()
        )
    }
}

extension RLMQuizRecordModel {
    convenience init(quizRecord: QuizRecord) {
        self.init(id: quizRecord.id, status: quizRecord.status)
    }
}

extension Collection where Element: Object {
    func asList() -> List<Element> {
        let list = List<Element>()
        list.append(objectsIn: self)
        return list
    }
}

extension List {
    convenience init<T: Collection>(collection: T) where T.Element == Element {
        self.init()
        append(objectsIn: collection)
    }
}
