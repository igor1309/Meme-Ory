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
    
    var stories: [Story] {
        switch size {
            case .systemSmall:
                return [entry.stories.first!]
            case .systemMedium:
                return Array(entry.stories.prefix(3))
            case .systemLarge:
                return entry.stories
            @unknown default:
                return entry.stories
        }
    }
    
    var body: some View {
        if entry.stories.isEmpty {
            Text("No stories here ☹️")
                .font(.title)
                .widgetURL(URL(string: URL.appHomeUrl))
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
        Text(story.storyText(maxCount: 300, maxLines: 3))
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
    
    // old version
    @ViewBuilder
    private func storyView(_ story: Story) -> some View {
        Link(destination: story.url) {
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
}

struct WidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WidgetEntryView(entry: Entry(date: Date(), stories: []))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            WidgetEntryView(entry: Entry(date: Date(), stories: [SampleData.story(storyIndex: 8), SampleData.story(storyIndex: 6)]))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            WidgetEntryView(entry: Entry(date: Date(), stories: [SampleData.story(storyIndex: 8), SampleData.story(storyIndex: 6)]))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            WidgetEntryView(entry: Entry(date: Date(), stories: [SampleData.story(), SampleData.story(storyIndex: 8), SampleData.story(storyIndex: 12), SampleData.story(), SampleData.story(storyIndex: 2), SampleData.story()]))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
