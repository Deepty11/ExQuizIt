//
//  PracticeSessionRecord.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 29/5/22.
//

import Foundation

struct PracticeSession {
    var id: String = UUID().uuidString
    var startTime: String = Date().getFormattedDate(format: Strings.DateFormat)
    var endTime: String = ""
    var quizRecords:[QuizRecord] = []
}

struct QuizRecord {
    var id: String = ""
    var status: PracticeQuizStatus.RawValue = PracticeQuizStatus.learning.rawValue
}
