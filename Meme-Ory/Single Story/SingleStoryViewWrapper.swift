//
//  SingleStoryViewWrapper.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SingleStoryComponent
import SwiftUI

struct SingleStoryViewWrapper: View {
    
    @ObservedObject var story: Story
    
    let switchViewMode: () -> Void
    let getRandomStory: () -> Void
    let showTagGrid: (Story) -> Void
    
    let maxTextLength = 5_000
    
    var body: some View {
        VStack(spacing: 16) {
            
            SingleStoryToolbar(
                isFavorite: story.isFavorite,
                hasReminder: story.hasReminder,
                switchViewMode: switchViewMode
            )
            
            SingleStoryView(
                text: story.text,
                maxTextLength: maxTextLength
            )
            .contentShape(Rectangle())
            .onTapGesture(count: 1, perform: getRandomStory)
            
            SingleStoryTagListButton(tagList: tagList) {
                showTagGrid(story)
            }
            
            Text("Tap card to get next random story")
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .font(.caption)
        }
        .padding([.top, .horizontal])
        .background(Color(UIColor.secondarySystemGroupedBackground).ignoresSafeArea())
    }
    
    private var tagList: String {
        story.tags.isEmpty ? "no tags" : story.tagList
    }
}

struct SingleStoryView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            SingleStoryViewWrapper(
                story: .preview,
                switchViewMode: {},
                getRandomStory: {},
                showTagGrid: { _ in }
            )
            .navigationTitle("Random/Widget Story")
            .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.sizeCategory, .large)
        .environment(\.colorScheme, .dark)
        .previewLayout(.fixed(width: 350, height: 700))
    }
}

extension Story {
    
    static let preview: Story = SampleData.story()
}
