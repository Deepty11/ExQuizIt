//
//  String+Filter.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 5/7/22.
//

import Foundation

extension String {
    func filter(with searchText: String) -> Bool {
        return self.range(of: searchText,
                          options: .caseInsensitive,
                          range: nil ,
                          locale: nil) != nil
    }
}
