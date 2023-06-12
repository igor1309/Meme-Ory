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
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 3) {
                story.text.storyText(maxTextLength: 1_000)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(20)
                
                if !story.tagList.isEmpty {
                    Label {
                        Text(story.tagList)
                    } icon: {
                        Image(systemName: "tag")
                            .imageScale(.small)
                    }
                    .foregroundColor(.orange)
                    .font(.caption)
                }
                
                Text("\(story.timestamp, formatter: Ory.storyFormatter)")
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .font(.caption)
            }
            
            HStack {
                if story.hasReminder {
                    Image(systemName: "bell")
                        .foregroundColor(Color(UIColor.systemTeal))
                    
                }
                
                if story.isFavorite {
                    Image(systemName: "star.circle")
                        .foregroundColor(Color(UIColor.systemOrange))
                }
            }
            .font(.caption)
        }
        .padding(.vertical, 3)
    }
}

struct StoryListRowView_Previews: PreviewProvider {
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
