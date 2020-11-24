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
        if filter.wrappedValue.isListLimited {
            fetchRequest.fetchLimit = filter.wrappedValue.listLimit
        }
        _stories = FetchRequest(fetchRequest: fetchRequest)
    }
    
    @State private var showFilter = false
    @State private var showListOptions = false
    @State private var showCreateSheet = false
    @State private var showConfirmation = false
    @State private var offsets = IndexSet()
    
    private var count: Int { context.realCount(for: fetchRequest) }
    
    var body: some View {
        List {
            TextField("Filter (at least 3 letters)", text: $filter.searchString)
                .searchModifier(text: $filter.searchString)
                .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            
            Section(header: Text("Stories: \(count)")) {
                ForEach(stories) { story in
                    StoryListRowView(story: story, filter: $filter)
                }
                .onDelete(perform: confirmDeletion)
            }
            .actionSheet(isPresented: $showConfirmation) {
                confirmationActionSheet()
            }
        }
        .navigationBarItems(leading: optionsButton(), trailing: createStoryButton())
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Stories")
    }
    
    private func confirmDeletion(offsets: IndexSet) {
        self.offsets = offsets
        showConfirmation = true
    }
    
    private func confirmationActionSheet() -> ActionSheet {
        ActionSheet(
            title: Text("Delete Story?"),
            message: Text("Are you sure? This cannot be undone."),
            buttons: [
                .destructive(Text("Yes, delete!")) { deleteStories() },
                .cancel({ offsets = [] })
            ]
        )
    }
    
    private func deleteStories() {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            offsets.map { stories[$0] }.forEach(context.delete)
            
            context.saveContext()
        }
    }
    
    private var optionsButtonColor: Color {
        if filter.isTagFilterActive || filter.isListLimited {
            return Color(UIColor.systemOrange)
        } else {
            return Color(UIColor.systemBlue)
        }
    }
    
    private func optionsButton() -> some View {
        Button {
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                showListOptions = true
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
        }
        .accentColor(optionsButtonColor)
        .sheet(isPresented: $showListOptions) {
            ListOptionView(filter: $filter)
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
            Button {
                let haptics = Haptics()
                haptics.feedback()
                
                withAnimation {
                    filter.areInIncreasingOrder.toggle()
                }
            } label: {
                Label("Sort \(filter.areInIncreasingOrder ? "Descending": "Ascending")", systemImage: filter.areInIncreasingOrder ? "arrow.up.arrow.down" : "arrow.up.arrow.down.square.fill")
            }
            Button {
                let haptics = Haptics()
                haptics.feedback()
                
                withAnimation {
                    filter.isListLimited.toggle()
                }
            } label: {
                Label(filter.isListLimited ? "Reset List Limit": "Set last Limit (\(filter.listLimit))",
                      systemImage: filter.isListLimited ? "infinity" : "arrow.up.and.down")
            }
        }
    }
    
    private func createStoryButton() -> some View {
        Button {
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                showCreateSheet = true
            }
        } label: {
            Image(systemName: "doc.badge.plus")
        }
        .sheet(isPresented: $showCreateSheet) {
            StoryEditorView()
                .environment(\.managedObjectContext, context)
        }
    }
}

fileprivate struct StoryListView_Testing: View {
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
        .previewLayout(.fixed(width: 350, height: 800))
    }
}
