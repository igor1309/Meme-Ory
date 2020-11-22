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
    
    var predicate: NSPredicate {
        let tagPredicate: NSPredicate
        if isTagFilterActive {
            tagPredicate = NSPredicate(format: "ANY %K IN %@", #keyPath(Story.tags_), Array(tags))
        } else {
            tagPredicate = NSPredicate.all
        }
        
        let searchStringPredicate: NSPredicate
        if searchString.count < 3 {
            searchStringPredicate = NSPredicate.all
        } else {
            searchStringPredicate = NSPredicate(format: "text_ CONTAINS[cd] %@", searchString)
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: [tagPredicate, searchStringPredicate])
    }
    
    mutating func reset() {
        tags = Set()
    }
}
