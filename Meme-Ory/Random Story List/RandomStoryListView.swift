//
//  RandomStoryListView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 07.12.2020.
//

import SwiftUI
import CoreData

struct RandomStoryListView: View {
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.scenePhase) private var scenePhase

    @EnvironmentObject private var filter: Filter
    @EnvironmentObject private var eventStore: EventStore
    
    @StateObject private var model: RandomStoryListViewModel
    
    init(context: NSManagedObjectContext) {
        _model = StateObject(wrappedValue: RandomStoryListViewModel(context: context))
    }
    
    private var columns: [GridItem] = [.init(.flexible())]
    
    var body: some View {
        NavigationView {
            List {
                if model.listType == .ordered {
                    TextField("Search (at least 3 letters)", text: $model.listOptions.searchString)
                        .searchModifier(text: $model.listOptions.searchString)
                }
                
                Section(header: sectionHeader()) {
                    if model.stories.isEmpty {
                        Button("Add Story", action: model.createNewStory)
                    }
                    
                    ForEach(model.stories) { story in
                        StoryListRowView(story: story, lineLimit: model.lineLimit)
                    }
                    .onDelete(perform: confirmDelete)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Random Stories", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: leadingMenu)
                ToolbarItem(placement: .navigationBarTrailing, content: trailingMenu)
            }
            .storyFileImporter(isPresented: $model.showingFileImporter)
            .fileExporter(isPresented: $model.showingFileExporter, document: model.document, contentType: .json, onCompletion: model.handleFileExporter)
            .actionSheet(item: $actionSheetID, content: actionSheet)
            .sheet(item: $model.sheetID, content: sheetView)
            .onTapGesture(count: 2, perform: model.update)
        }
        .onAppear(perform: model.update)
        .onDisappear(perform: context.saveContext)
        .onOpenURL(perform: model.handleOpenURL)
        .onChange(of: scenePhase, perform: handleScenePhase)
        
    }
    
    private func sectionHeader() -> some View {
        model.stories.isEmpty ? Text("No Stories") : Text("Stories: \(model.stories.count)")
    }
    
    private func handleScenePhase(scenePhase: ScenePhase) {
        if scenePhase == .background {
            print("RandomStoryListView: gone to background")
            model.deleteTemporaryFile()
            context.saveContext()
        }
    }
    
    
    //  MARK: Toolbar items
    
    private func leadingMenu() -> some View {
        Menu {
            RandomListOptionsMenu(model: model)
        } label: {
            Label("List Options", systemImage: "slider.horizontal.3")
                .labelStyle(IconOnlyLabelStyle())
        }
        .accentColor(model.listOptions.isActive ? Color(UIColor.systemOrange) : Color(UIColor.systemBlue))
    }
    
    private func trailingMenu() -> some View {
        Menu {
            //  MARK: - FINISH THIS:
            //
            RandomStoryListActions(model: model)
        } label: {
            Label("", systemImage: "ellipsis.circle")
                .labelStyle(IconOnlyLabelStyle())
        }
    }
    
    
    //  MARK: Sheets
    
    @ViewBuilder
    private func sheetView(sheetIdentifier: RandomStoryListViewModel.SheetID) -> some View {
        Group {
            switch sheetIdentifier {
                case .tags: Text("TBD")
                //  MARK: - FINISH THIS:
                //
                
                case .listOptions:
                    ListOptionsView(model: model)
                    
                case .edit: Text("TBD")
                //  MARK: - FINISH THIS:
                //
                
                case .new:
                    NavigationView {
                        StoryEditorView()
                    }
                    
                case .maintenance:
                    MaintenanceView(context: context)
                    
                case .singleStoryUI:
                    SingleStoryViewWrapper(context: context)
                    
            }
        }
        .environment(\.managedObjectContext, context)
        .environmentObject(filter)
        .environmentObject(eventStore)
    }
    
    //  MARK: Action Sheets
    
    @State private var actionSheetID: ActionSheetID?
    
    enum ActionSheetID: Identifiable {
        case delete, remindMe
        var id: Int { hashValue }
    }
    
    @State private var indexSet = IndexSet()
    
    private func confirmDelete(_ indexSet: IndexSet) {
        self.indexSet = indexSet
        actionSheetID = .delete
    }
    
    private func actionSheet(actionSheetID: ActionSheetID) -> ActionSheet {
        switch actionSheetID {
            case .delete:
                return confirmationActionSheet()
            case .remindMe:
                //  MARK: - FINISH THIS:
                //
                return ActionSheet(title: Text("TBD"))
        }
    }
    
    private func confirmationActionSheet() -> ActionSheet {
        ActionSheet(
            title: Text("Delete Story?".uppercased()),
            message: Text("Are you sure? This cannot be undone."),
            buttons: [
                .destructive(Text("Yes, delete!")) { model.delete(at: indexSet) },
                .cancel()
            ]
        )
    }
}

struct RamdonStoryListView_Previews: PreviewProvider {
    @State static var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        Group {
            List {
                RandomStoryListActions(model: RandomStoryListViewModel(context: context))
            }
            .previewLayout(.fixed(width: 350, height: 500))
            
            RandomStoryListView(context: context)
                .preferredColorScheme(.dark)
        }
        .environment(\.sizeCategory, .extraLarge)
        .environment(\.managedObjectContext, context)
        .environmentObject(Filter())
        .environmentObject(EventStore())
    }
}
