//
//  PracticeSessionModel.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 29/5/22.
//

import Foundation
import RealmSwift

class PracticeSessionModel: Object {
    @Persisted var id: String = UUID().uuidString
    @Persisted var startTime: String?
    @Persisted var endTime: String?
    @Persisted var practiceRecords: List<PracticeQuizRecordModel>
    
    init(startTime: String, endTime: String, practiceRecords: List<PracticeQuizRecordModel>) {
        self.startTime = startTime
        self.endTime = endTime
        self.practiceRecords = practiceRecords
    }
}

class PracticeQuizRecordModel: Object {
    @Persisted var id: String
    @Persisted var status: PracticeQuizStatus.RawValue?
}
