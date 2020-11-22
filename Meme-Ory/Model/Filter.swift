//
//  Filter.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

extension NSPredicate {
    static var all = NSPredicate(format: "TRUEPREDICATE")
    static var none = NSPredicate(format: "FALSEPREDICATE")
}

struct Filter {
    
    var searchString = ""
    var tags = Set<Tag>()
    
    var isActive: Bool { !tags.isEmpty }
    
    var tagList: String {
        tags.map { $0.name }.joined(separator: ", ")
    }
    
    var predicate: NSPredicate {
        if isActive {
            return NSPredicate(format: "ANY %K IN %@", #keyPath(Story.tags_), Array(tags))
        } else {
            return NSPredicate.all
        }
    }
    
    mutating func reset() {
        tags = Set()
    }
}
