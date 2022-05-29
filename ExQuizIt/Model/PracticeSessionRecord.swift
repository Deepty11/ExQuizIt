//
//  PracticeSessionRecord.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 29/5/22.
//

import Foundation

struct PracticeSession {
    var id: String = UUID().uuidString
    var startTime: String?
    var endTime: String?
    var practiceRecords:[PracticeRecord]?
    
    init() {
        startTime = Date().getFormattedDate(format: Strings.DateFormat)
    }
}

struct PracticeRecord {
    var id: String
    var status: PracticeQuizStatus.RawValue
}
