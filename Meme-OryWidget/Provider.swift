//
//  Provider.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 25.11.2020.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), stories: [SampleData.story(), SampleData.story()])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = Entry(date: Date(), stories: [SampleData.story(), SampleData.story()])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [Entry] = []
        
        // Generate a timeline consisting of # entries
        let currentDate = Date()
        for offset in 0 ..< 6 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: 10 * offset, to: currentDate)!
            
            let viewContext = PersistenceController.shared.container.viewContext
            let request = Story.fetchRequest(NSPredicate.all)
            // request # of random stories
            let count = viewContext.realCount(for: request)
            let limit = 9
            let maxOffset = max(0, count - limit)
            request.fetchOffset = Int(arc4random_uniform(UInt32(maxOffset)))
            request.fetchLimit = limit
            
            if let results = try? viewContext.fetch(request) {
                let newEntry = Entry(date: entryDate, stories: results)
                entries.append(newEntry)
            }
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
