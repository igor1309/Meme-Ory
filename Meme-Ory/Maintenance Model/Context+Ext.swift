//
//  Context+Ext.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import CoreData

extension NSManagedObjectContext {
    
    func getTag(withName name: String) -> Tag {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Tag.name_), name)
        let request = Tag.fetchRequest(predicate)
        
        if let fetch = try? self.fetch(request),
           let tag = fetch.first {
            return tag
        } else {
            let tag = Tag(context: self)
            tag.name = name
            self.saveContext()
            return tag
        }
    }
    
    func deleteStories(withTag tag: Tag) {
        let predicate = NSPredicate(format: "ANY %K == %@", #keyPath(Story.tags_), tag)
        let request = Story.fetchRequest(predicate)
        
        guard let fetch = try? self.fetch(request) else {
            print("deleteStories: fetch error")
            return
        }
        
        for story in fetch {
            self.delete(story)
        }
        
        self.saveContext()
    }
}


