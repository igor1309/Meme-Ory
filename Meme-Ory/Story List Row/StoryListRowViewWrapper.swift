//
//  StoryListRowViewWrapper.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

struct StoryListRowViewWrapper: View {
    
    @ObservedObject private var story: Story
    
    init(story: Story) {
        self.story = story
    }
    
    var body: some View {
        StoryListRowView(
            text: story.text,
            tagList: story.tagList,
            timestamp: story.timestamp,
            hasReminder: story.hasReminder,
            isFavorite: story.isFavorite
        )
    }
}

struct StoryListRowViewWrapper_Previews: PreviewProvider {
    
    @State static var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        NavigationView {
            List {
                StoryListRowViewWrapper(
                    story: SampleData.story())
                
                Section {
                    StoryListRowViewWrapper(
                        story: SampleData.story())
                    StoryListRowViewWrapper(
                        story: SampleData.story(storyIndex: 1)
                    )
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Story List Row View")
            .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.sizeCategory, .large)
        .environment(\.colorScheme, .dark)
        .previewLayout(.fixed(width: 350, height: 700))
    }
}
