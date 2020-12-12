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
    
    //  MARK: Fetch Requests
    
    /// with default sortDescriptors (descending timestmp, then ascending text)
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Tag> {
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Tag.name_), ascending: true)
        return Tag.fetchRequest(predicate, sortDescriptors: [sortDescriptor])
    }
    
    static func fetchRequest(_ predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]) -> NSFetchRequest<Tag> {
        let request = NSFetchRequest<Tag>(entityName: "Tag")
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        return request
    }
    
}

extension Tag: Comparable {
    public static func < (lhs: Tag, rhs: Tag) -> Bool {
        lhs.name < rhs.name
    }
}
