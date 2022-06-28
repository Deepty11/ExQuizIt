//
//  RLMCategoryModel.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 28/6/22.
//

import Foundation
import RealmSwift

class RLMCategoryModel: Object {
    @Persisted var id: String = UUID().uuidString
    @Persisted var name: String
    
    override init() { }
    
    init(name: String) {
        self.name = name
    }
}

extension RLMCategoryModel {
    convenience init(category: Category) {
        self.init(name: category.name ?? "")
    }
    
    func update(with category: Category) {
        self.name = category.name ?? ""
    }
    
    func asCategory() -> Category {
        Category(id: id, name: name)
    }
}

struct Category {
    var id: String?
    var name: String?
}
