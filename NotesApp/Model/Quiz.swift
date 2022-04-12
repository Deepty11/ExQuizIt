//
//  Quiz.swift
//  NotesApp
//
//  Created by rehnuma.deepty on 12/4/22.
//

import Foundation
import RealmSwift

class Quiz: Object{
    @Persisted var question: String?
    @Persisted var answer: String?
    @Persisted var isKnown: Bool
}
