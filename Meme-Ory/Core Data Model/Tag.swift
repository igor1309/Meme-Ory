//
//  Tag.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import CoreData

extension Tag {
    var name: String {
        get { name_ ?? "" }
        set { name_ = newValue }
    }
}

extension Tag: Comparable {
    public static func < (lhs: Tag, rhs: Tag) -> Bool {
        lhs.name < rhs.name
    }
}
