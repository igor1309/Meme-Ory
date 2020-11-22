//
//  Story.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import CoreData

extension Story {
    var text: String {
        get { text_ ?? "" }
        set { text_ = newValue }
    }
    
    var tags: [Tag] {
        get { (tags_ as? Set<Tag> ?? []).sorted() }
        set { tags_ = Set(newValue) as NSSet }
    }
    
    var tagList: String {
        tags.map { $0.name }.joined(separator: ", ")
    }
}
