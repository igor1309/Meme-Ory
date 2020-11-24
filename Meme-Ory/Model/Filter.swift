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
    /// sort order
    var areInIncreasingOrder: Bool = true
    
    var searchString: String = ""
    /// Limiting Stories List (number of stories listed))
    var isListLimited: Bool = false
    var listLimit: Int = 6
    static var listLimitOptions: [Int] = Array(1..<5).map { $0 * 6 }

    var tags = Set<Tag>()
    
    var isTagFilterActive: Bool { !tags.isEmpty }
    
    var tagList: String {
        tags.map { $0.name }.sorted().joined(separator: ", ")
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
