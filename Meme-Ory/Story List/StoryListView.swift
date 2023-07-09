//
//  StoryListView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

struct StoryListView<Stories, StoryListRowView>: View
where Stories: RandomAccessCollection<Story>,
      StoryListRowView: View {
    
    let stories: Stories
    let storyListRowView: (Story) -> StoryListRowView
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
                stories: [],
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
