//
//  RLMCategoryModel.swift
//  ExQuizIt
//
//  Created by Rehnuma Reza on 28/6/22.
//

import Foundation
import RealmSwift

class RLMCategoryModel: Object {
    @Persisted var id: String
    @Persisted var name: String
    
    override init() { }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

extension RLMCategoryModel {
    convenience init(category: Category) {
        self.init(id: category.id, name: category.name)
    }
    
    func update(with category: Category) {
        self.id = category.id
        self.name = category.name
    }
    
    func asCategory() -> Category {
        Category(id: id, name: name)
    }
}

struct Category {
    var id: String = UUID().uuidString
    var name: String
}
