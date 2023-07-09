//
//  StoryListView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import CoreData
import SwiftUI

struct StoryListView: View {
    
    let context: NSManagedObjectContext
    @ObservedObject var model: MainViewModel
    @ObservedObject var eventStore: EventStore
    
    @FetchRequest var stories: FetchedResults<Story>
    
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
    
    private func storyListRowView(story: Story) -> some View {
        
        StoryListRowViewWrapper(story: story)
            .contentShape(Rectangle())
            .contextMenu {
                ListRowActionButtons(story: story)
            }
            .onAppear {
                eventStore.reminderCleanup(
                    for: story,
                    in: context
                )
            }
    }
}

struct StoryListView_Previews: PreviewProvider {
    
    @State static var context = SampleData.preview.container.viewContext
    
    static let request: FetchRequest<Story> = {
        let request = Story.fetchRequest(.all, sortDescriptors: [])
        return FetchRequest(fetchRequest: request)
    }()
    
    static var previews: some View {
        NavigationView {
            StoryListView(
                context: context,
                model: .init(context: context),
                eventStore: .init(),
                stories: request,
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
