//
//  StoryListView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

struct StoryListView<StoryListRowView: View>: View {
    
    @FetchRequest var stories: FetchedResults<Story>
    
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
    
    static let request: FetchRequest<Story> = {
        let request = Story.fetchRequest(.all, sortDescriptors: [])
        return FetchRequest(fetchRequest: request)
    }()
    
    static var previews: some View {
        NavigationView {
            StoryListView(
                stories: request,
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
