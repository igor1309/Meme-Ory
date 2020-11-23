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
    
    var isTagFilterActive: Bool { !tags.isEmpty }
    
    var tagList: String {
        tags.map { $0.name }.joined(separator: ", ")
    }
    
    private var tagPredicate: NSPredicate {
        isTagFilterActive ?
            NSPredicate(format: "ANY %K IN %@", #keyPath(Story.tags_), Array(tags))
            : NSPredicate.all
    }
    
    private var searchStringPredicate: NSPredicate {
        searchString.count >= 3 ?
            NSPredicate(format: "text_ CONTAINS[cd] %@", searchString)
            : NSPredicate.all
    }
    
    var predicate: NSPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: [tagPredicate, searchStringPredicate])
    }
    
    mutating func reset() {
        tags = Set()
    }
}
