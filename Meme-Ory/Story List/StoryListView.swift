//
//  StoryListView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

struct StoryListView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var model: MainViewModel
    
    @FetchRequest var stories: FetchedResults<Story>
    
    var body: some View {
        List {
            Section(header: Text("Stories: \(stories.count)")) {
                ForEach(stories, content: StoryListRowView.init)
                    .onDelete(perform: confirmDelete)
                    .actionSheet(isPresented: $showingConfirmation, content: confirmActionSheet)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .toolbar(content: toolbar)
        .sheet(item: $model.sheetID, content: sheetView)
    }
    
    
    //  MARK: - Sheets
    
    @ViewBuilder
    private func sheetView(sheetID: MainViewModel.SheetID) -> some View {
        switch sheetID {
            case .listOptions:
                ListOptionsView(model: model)
                
            default: Text("TBD")
        }
    }
    
    
    //  MARK: - Toolbar
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                ListActionButtons()
            } label: {
                Label("Story Menu", systemImage: "list.bullet")
            }
        }
    }
    
    
    //  MARK: - Handle Delete
    
    @State private var showingConfirmation = false
    @State private var indexSet = IndexSet()
    
    private func confirmDelete(_ indexSet: IndexSet) {
        self.indexSet = indexSet
        showingConfirmation = true
    }
    
    private func confirmActionSheet() -> ActionSheet {
        ActionSheet(
            title: Text("Delete Story?".uppercased()),
            message: Text("Are you sure? This cannot be undone."),
            buttons: [
                .destructive(Text("Yes, delete!"), action: delete),
                .cancel()
            ]
        )
    }
    
    private func delete() {
        for index in indexSet {
            context.delete(stories[index])
        }
        
        context.saveContext()
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
            StoryListView(stories: request)
                .navigationTitle("Story List View")
                .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.managedObjectContext, context)
        .environmentObject(MainViewModel(context: context))
        .environmentObject(EventStore())
        .environment(\.sizeCategory, .large)
        .environment(\.colorScheme, .dark)
        .previewLayout(.fixed(width: 350, height: 700))
    }
}
