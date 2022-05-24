//
//  String+Utils.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 24/5/22.
//

import Foundation

extension String {
    func trim() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isVisuallyEmpty: Bool {
        trim().isEmpty
    }
}
