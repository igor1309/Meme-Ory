//
//  Meme_OryWidget.swift
//  Meme-OryWidget
//
//  Created by Igor Malyarov on 24.11.2020.
//

import WidgetKit
import SwiftUI
import CoreData

struct Entry: TimelineEntry {
    var date: Date
    var story: Story
}

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), story: SampleData.story())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = Entry(date: Date(), story: SampleData.story())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [Entry] = []
        
        // Generate a timeline consisting of six entries
        let currentDate = Date()
        for offset in 0 ..< 6 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: 10 * offset, to: currentDate)!
            
            let viewContext = PersistenceController.shared.container.viewContext
            let request = Story.fetchRequest(NSPredicate.all)
            // request 1 random Story
            let count = viewContext.realCount(for: request)
            request.fetchOffset = Int(arc4random_uniform(UInt32(count)))
            request.fetchLimit = 1
            
            if let results = try? viewContext.fetch(request) {
                debugPrint("Widget fetched from data store")
                let newEntries = results.map { Entry(date: entryDate, story: $0) }
                entries.append(contentsOf: newEntries)
            }
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var size
    
    let entry: Entry
    
    var story: Story { entry.story }
    
    var body: some View {
        switch size {
            case .systemSmall:
                Text(story.storyText(maxCount: 100, maxLines: 3))
                    .font(.footnote)
                    .padding()
            case .systemMedium:
                VStack(alignment: .leading) {
                    Text(story.storyText(maxCount: 180, maxLines: 4))
                        .font(.footnote)
                    Text(story.timestamp, style: .relative)
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                        .font(.caption)
                }
                .padding(.horizontal)
            case .systemLarge:
                VStack(alignment: .leading) {
                    Text(story.storyText(maxCount: 360, maxLines: 8))
                        .font(.footnote)
                    Text(story.timestamp, style: .relative)
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                        .font(.caption)
                }
                .padding(.horizontal)
            @unknown default:
                Text(story.storyText(maxCount: 100, maxLines: 3))
                    .font(.footnote)
        }
    }
}

@main
struct Meme_OryWidget: Widget {
    let kind: String = "Meme_OryWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct Meme_OryWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetEntryView(entry: Entry(date: Date(), story: SampleData.story(storyIndex: 8)))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            WidgetEntryView(entry: Entry(date: Date(), story: SampleData.story(storyIndex: 8)))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            WidgetEntryView(entry: Entry(date: Date(), story: SampleData.story()))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
