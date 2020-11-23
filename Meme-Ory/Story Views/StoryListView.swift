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
    
    /// used to pass to TagFilterView via filterButton
    @Binding var filter: Filter
    /// used to count
    private let fetchRequest: NSFetchRequest<Story>
    
    @FetchRequest private var stories: FetchedResults<Story>
    
    init(filter: Binding<Filter>) {
        _filter = filter
        fetchRequest = Story.fetchRequest(filter.wrappedValue.predicate, areInIncreasingOrder: filter.wrappedValue.areInIncreasingOrder)
        _stories = FetchRequest(fetchRequest: fetchRequest)
    }
    
    @State private var showFilter = false
    @State private var showSort = false
    @State private var showCreateSheet = false
    
    private var count: Int { context.realCount(for: fetchRequest) }
    
    var body: some View {
        List {
            TextField("Filter (at least 3 letters)", text: $filter.searchString)
                .searchModifier(text: $filter.searchString)
                .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            
            Section(header: Text("Stories: \(count)")) {
                ForEach(stories, content: StoryListRowView.init)
                    .onDelete(perform: deleteStories)
            }
        }
        .navigationBarItems(
            leading: HStack {
                filterButton()
                sortButton()
            },
            trailing: createStoryButton())
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Stories")
    }
    
    private func createStoryButton() -> some View {
        Button(action: createStory) {
            Image(systemName: "doc.badge.plus")
        }
        .sheet(isPresented: $showCreateSheet) {
            StoryEditorView()
                .environment(\.managedObjectContext, context)
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
            Image(systemName: filter.isTagFilterActive ? "tag.fill" : "tag")
        }
        .sheet(isPresented: $showFilter) {
            TagFilterView(filter: $filter)
                .environment(\.managedObjectContext, context)
        }
        .contextMenu {
            if filter.isTagFilterActive {
                Button {
                    let haptics = Haptics()
                    haptics.feedback()
                    
                    withAnimation {
                        filter.reset()
                    }
                } label: {
                    Label("Reset Tags", systemImage: "tag.slash.fill")
                }
            } else {
                EmptyView()
            }
        }
    }
    
    private func sortButton() -> some View {
        let image = filter.areInIncreasingOrder ? "arrow.up.arrow.down" : "arrow.up.arrow.down.square.fill"
        
        return Button {
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                showSort = true
            }
        } label: {
            Image(systemName: image)
        }
        .sheet(isPresented: $showSort) {
            SortOptionView(filter: $filter)
        }
        .contextMenu {
            Button {
                let haptics = Haptics()
                haptics.feedback()
                
                withAnimation {
                    filter.areInIncreasingOrder.toggle()
                }
            } label: {
                Label("Sort \(filter.areInIncreasingOrder ? "Descending": "Ascending")",
                      systemImage: image)
            }
        }
    }
    
    private func createStory() {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            showCreateSheet = true
        }
    }
    
    private func deleteStories(offsets: IndexSet) {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {            
            offsets.map { stories[$0] }.forEach(context.delete)
            
            context.saveContext()
        }
    }
}

struct StoryListView_Testing: View {
    @State var filter = Filter()
    
    var body: some View {
        StoryListView(filter: $filter)
    }
}

struct StoryListView_Previews: PreviewProvider {
    @State static var filter = Filter()
    
    static var previews: some View {
        NavigationView {
            StoryListView_Testing()
        }
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 350, height: 1000))
    }
}
