//
//  WidgetEntryView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 25.11.2020.
//

import WidgetKit
import SwiftUI
import CoreData

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var size
    
    let entry: Entry
    
    let publisherForCoreDataRemoteNotifications = NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
    
    var stories: [Story] {
        switch size {
            case .systemSmall:  return entry.stories.isEmpty ? [] : [entry.stories.first!]
            case .systemMedium: return Array(entry.stories.prefix(3))
            case .systemLarge:  return entry.stories
            @unknown default:   return entry.stories
        }
    }
    
    var body: some View {
        content
        .onReceive(publisherForCoreDataRemoteNotifications) { _ in
            // https://stackoverflow.com/a/63971182/11793043
            // make sure you don't call this too often
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if stories.isEmpty {
            Text("No stories here ☹️")
                .font(.title)
                .widgetURL(URL(string: URL.appHomeURL))
        } else {
            VStack(spacing: 12) {
                ForEach(stories, content: storyRowView)
            }
            .padding(.vertical)
        }
    }
    
    @ViewBuilder
    private func storyRowView(_ story: Story) -> some View {
        switch size {
            case .systemSmall:
                rowLabel(story).widgetURL(story.url)
            case .systemMedium, .systemLarge:
                Link(destination: story.url, label: { rowLabel(story) })
            @unknown default:
                Text("TBD")
        }
    }
    
    private func rowLabel(_ story: Story) -> some View {
        Text(storyText(of: story))
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .contentShape(Rectangle())
    }
    
    private func storyText(of story: Story) -> String {
        switch size {
            case .systemSmall:
                return story.storyText(maxCount: 100, maxLines: 3)
            case .systemMedium:
                return story.storyText(maxCount: 180, maxLines: 4)
            case .systemLarge:
                return story.storyText(maxCount: 360, maxLines: 8)
            @unknown default:
                return story.storyText(maxCount: 100, maxLines: 3)
        }
    }
}

struct WidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetEntryView(entry: Entry.sampleEmpty)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            WidgetEntryView(entry: Entry.sampleTwoStories)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            WidgetEntryView(entry: Entry.sampleTwoStories)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            WidgetEntryView(entry: Entry.sampleMany)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
