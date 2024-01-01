//
//  StoryListView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

struct StoryListView<Stories: RandomAccessCollection, StoryListRowView>: View
where Stories.Element: Identifiable,
      StoryListRowView: View {
    
    let stories: Stories
    let storyListRowView: (Stories.Element) -> StoryListRowView
    let confirmDelete: (IndexSet) -> Void
    
    var body: some View {
        List {
            Section(header: Text("Stories: \(stories.count)")) {
                ForEach(stories, content: storyListRowView)
                    .onDelete(perform: confirmDelete)
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct StoryListView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            StoryListView(
                stories: [PreviewArticle].preview,
                storyListRowView: { Text($0.text) },
                confirmDelete: { _ in }
            )
            .navigationTitle("Story List View")
            .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.sizeCategory, .large)
        .environment(\.colorScheme, .dark)
        .previewLayout(.fixed(width: 350, height: 700))
    }
}

// MARK: - Preview Content

private struct PreviewArticle: Identifiable {
    
    let text: String
    
    var id: Int { text.hashValue }
}

private extension Array where Element == PreviewArticle {
    
    static let preview: Self = [
        "Leaves rustled gently in the breeze.",
        "A mysterious figure appeared at midnight.",
        "The old clock struck twelve, echoing in the silent hall.",
        "Sunlight peeked through the clouds, illuminating the valley.",
        "In the garden, a hidden path led to an ancient fountain.",
        "She whispered a secret, changing everything.",
        "The stars above seemed to dance in the night sky.",
        "A lost kitten found its way home after a long adventure.",
        "Under the moonlight, the old bridge cast a haunting shadow.",
        "He discovered an old letter, revealing truths about his family's past.",
    ].map(PreviewArticle.init(text:))
}

