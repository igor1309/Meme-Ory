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
    
    var hasReminder: Bool {
        !calendarItemIdentifier.isEmpty
    }
    
    var url: URL {
        let absoluteString = objectID.uriRepresentation().absoluteString
        let url = URL(string: String(format: URL.appDetailsURLFormat, absoluteString))!
        
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
    
    
    //  MARK: Reminder
    
    func reminderCleanUp(eventStore: EventStore, context: NSManagedObjectContext) {
        //  reminder could be deleted from Reminders but Story still store reference (calendarItemIdentifier)
        if calendarItemIdentifier != "",
           eventStore.accessGranted {
            // if story has a pointer to the  reminder but reminder was deleted, clear the pointer
            let reminder = eventStore.reminder(for: self)
            if reminder == nil {
                calendarItemIdentifier_ = nil
                context.saveContext()
            }
        }
    }
    
    //  MARK: - FINISH THIS
    // next month: next month 1st day
    // next weeek: next monday
    // next year: next Jan 1
    //
    func remindMeNext(_ component: Calendar.Component, hour: Int = 9, eventStore: EventStore, context: NSManagedObjectContext) {
        guard eventStore.accessGranted,
              let calendarItemIdentifier = eventStore.addReminder(for: self, component: component, hour: hour) else { return }
        
        Ory.withHapticsAndAnimation {
            self.calendarItemIdentifier = calendarItemIdentifier
            context.saveContext()
        }
    }
    
    
    //  MARK: FetchRequest
    
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Story> {
        let sortDescriptor = NSSortDescriptor(key: #keyPath(Story.timestamp_), ascending: true)
        return Story.fetchRequest(predicate, sortDescriptors: [sortDescriptor])
    }
    
    static func fetchRequest(_ predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]) -> NSFetchRequest<Story> {
        let request = NSFetchRequest<Story>(entityName: "Story")
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        return request
    }
    
    
    //  MARK: - FINISH THIS: NOT SURE THIS IS WORKING RIGHT
    static func last(in context: NSManagedObjectContext) -> Story? {
        let request = Story.fetchRequest(NSPredicate.all)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Story.timestamp_), ascending: false)]
        request.fetchLimit = 1
        if let fetch = try? context.fetch(request) {
            return fetch.first
        } else {
            return nil
        }
    }
}


//  MARK: Export

extension Sequence where Element == Story {
    /// convert [Story] to [String] and encode
    func exportTexts() -> Data? {
        let briefs = map(\.text)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        return try? encoder.encode(briefs)
    }
}
