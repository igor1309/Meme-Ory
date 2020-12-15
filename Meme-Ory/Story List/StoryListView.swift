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
    @EnvironmentObject private var eventStore: EventStore
    
    @FetchRequest var stories: FetchedResults<Story>
    
    var body: some View {
        List {
            Section(header: Text("Stories: \(stories.count)")) {
                ForEach(stories, content: StoryListRowView.init)
                    .onDelete(perform: confirmDelete)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .toolbar(content: toolbar)
        .sheet(item: $model.sheetID, content: sheetView)
        .actionSheet(item: $model.actionSheetID, content: actionSheet)
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
                Image(systemName: "list.bullet")
                    .frame(width: 44, height: 44, alignment: .trailing)
                    .if(model.listOptions.isActive) { $0.foregroundColor(Color(UIColor.systemOrange)) }
            }
        }
    }
    
    
    //  MARK: - Action Sheets
    
    private func actionSheet(actionSheetID: MainViewModel.ActionSheetID) -> ActionSheet {
        switch actionSheetID {
            case .remindMe:
                if let storyToEdit = model.storyToEdit {
                    return eventStore.remindMeActionSheet(for: storyToEdit, in: context)
                } else {
                    return ActionSheet(title: Text("ERROR getting story"))
                }
                
            case .delete:
                return deleteConfirmActionSheet()
        }
    }
    
    
    //  MARK: - Handle Delete
    
    @State private var indexSet = IndexSet()
    
    private func confirmDelete(_ indexSet: IndexSet) {
        self.indexSet = indexSet
        model.deleteStoryAction()
    }
    
    private func deleteConfirmActionSheet() -> ActionSheet {
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
        Ory.withHapticsAndAnimation {
            for index in self.indexSet {
                self.context.delete(self.stories[index])
            }
            
            self.context.saveContext()
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
