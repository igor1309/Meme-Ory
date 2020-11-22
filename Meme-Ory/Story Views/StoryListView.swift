//
//  StoryListView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI
import CoreData

struct StoryListView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Story.timestamp, ascending: true)],
        animation: .default)
    private var stories: FetchedResults<Story>
    
    @State private var filter: Filter = Filter()
    @State private var showFilter = false
    @State private var showCreateSheet = false
    
    var body: some View {
        List {
            SearchView(filter: $filter)
            
            Section {
                ForEach(stories, content: StoryRowView.init)
                    .onDelete(perform: deleteStorys)
            }
        }
        .navigationBarItems(leading: filterButton(), trailing: createStoryButton())
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Stories")
    }
    
    private func createStoryButton() -> some View {
        Button(action: createStory) {
            Image(systemName: "doc.badge.plus")
        }
        .sheet(isPresented: $showCreateSheet) {
            StoryEditorView()
        }
    }
    private func filterButton() -> some View {
        Button {
            let haptics = Haptics()
            haptics.feedback()

            withAnimation {
                showFilter = true
            }
            
        } label: {
            Image(systemName: filter.isActive ? "tag.fill" : "tag")
        }
        .sheet(isPresented: $showFilter) {
            TagFilter(filter: $filter)
        }
    }
    
    private func createStory() {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            showCreateSheet = true
        }
    }
    
    private func deleteStorys(offsets: IndexSet) {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {            
            offsets.map { stories[$0] }.forEach(context.delete)
            
            context.saveContext()
        }
    }
}

struct StoryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StoryListView()
                .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 350, height: 800))
    }
}
