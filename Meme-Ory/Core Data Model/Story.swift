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
    
    var timestamp: Date {
        get { timestamp_ ?? .distantPast }
        set { timestamp_ = newValue }
    }
    
    var tags: [Tag] {
        get { (tags_ as? Set<Tag> ?? []).sorted() }
        set { tags_ = Set(newValue) as NSSet }
    }
    
    var tagList: String {
        tags.map { $0.name }.joined(separator: ", ")
    }
    
    var calendarItemIdentifier: String {
        get { calendarItemIdentifier_ ?? "" }
        set { calendarItemIdentifier_ = newValue }
    }
    
    var url: URL {
        let absoluteString = objectID.uriRepresentation().absoluteString
        let url = URL(string: String(format: URL.appDetailsUrlFormat, absoluteString))!
        
        return url
    }

    func storyText(maxCount: Int = 100, maxLines: Int = 3) -> String {
        var text = self.text
        if text.count > maxCount {
            text = text.prefix(maxCount).appending(" ...")
        }
        
        let lines = text.components(separatedBy: "\n")
        if lines.count > maxLines {
            text = lines.prefix(maxLines).joined(separator: "\n").appending(" ...")
        }
        
        return text
    }
    
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Story> {
        Story.fetchRequest(predicate, areInIncreasingOrder: true)
    }
    
    static func fetchRequest(_ predicate: NSPredicate, areInIncreasingOrder: Bool) -> NSFetchRequest<Story> {
        let request = NSFetchRequest<Story>(entityName: "Story")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp_", ascending: areInIncreasingOrder)]
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
