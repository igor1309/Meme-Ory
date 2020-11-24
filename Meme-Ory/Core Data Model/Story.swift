//
//  Story.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI
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
    
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Story> {
        Story.fetchRequest(predicate, areInIncreasingOrder: true)
    }
    
    static func fetchRequest(_ predicate: NSPredicate, areInIncreasingOrder: Bool) -> NSFetchRequest<Story> {
        let request = NSFetchRequest<Story>(entityName: "Story")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: areInIncreasingOrder)]
        request.predicate = predicate
        return request
    }
    
    static func requestRandom(in context: NSManagedObjectContext) -> NSFetchRequest<Story> {
        let request = Story.fetchRequest(NSPredicate.all)
        
        let count = context.realCount(for: request)
        debugPrint("context.realCount: \(count)")
        request.fetchOffset = Int(arc4random_uniform(UInt32(count)))
        debugPrint("fetchOffset: \(request.fetchOffset)")

        request.fetchLimit = 1

        return request
    }
}
