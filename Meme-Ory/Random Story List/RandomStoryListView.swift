//
//  RandomStoryListView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 07.12.2020.
//

import SwiftUI
import CoreData

struct RandomStoryListViewWrapper: View {
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.scenePhase) private var scenePhase

    @EnvironmentObject private var model: RandomStoryListViewModel

    var body: some View {
        NavigationView {
            RandomStoryListView()
//                .sheet(item: $model.textsStruct, content: importSheetView)
        }
        .sheet(item: $model.sheetID, content: sheetView)
        .onAppear(perform: model.update)
        .onDisappear(perform: context.saveContext)
        //.onOpenURL(perform: handleOpenURL)
        .onChange(of: scenePhase, perform: handleScenePhase)
        .alert(isPresented: $showingFailedImportAlert, content: failedImportAlert)
        //.sheet(item: $model.textsStruct, content: importSheetView)
    }
    
    
    private func handleScenePhase(scenePhase: ScenePhase) {
        if scenePhase == .background {
            print("RandomStoryListView: gone to background")
            model.deleteTemporaryFile()
            context.saveContext()
        }
    }
    
    private func importSheetView(textsStruct: RandomStoryListViewModel.TextsStruct) -> some View {
        ImportTextView(texts: textsStruct.texts)
            .environment(\.managedObjectContext, context)
    }
    
    @ViewBuilder
    private func sheetView(sheetID: RandomStoryListViewModel.SheetID) -> some View {
        Group {
            switch sheetID {
                case .importFile:
                    if let textsStruct = model.textsStruct,
                       let texts = textsStruct.texts {
                        ImportTextView(texts: texts)
                    } else {
                        Text("Error creating import sheet")
                    }
                    
                default: Text("Error")
            }
        }
        .environment(\.managedObjectContext, context)
    }


    
    //  MARK: - Failed Import Alert
    
    @State private var showingFailedImportAlert = false
    
    private func failedImportAlert() -> Alert {
        Alert(title: Text("Error"), message: Text("Can't process yuor request.\nSorry about that"), dismissButton: Alert.Button.cancel(Text("Ok")))
    }

}


//  MARK: - Random Story List View

struct RandomStoryListView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var filter: Filter
    @EnvironmentObject private var eventStore: EventStore
    @EnvironmentObject private var model: RandomStoryListViewModel
    
    var body: some View {
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
                    OLDStoryListRowView(story: story, lineLimit: model.lineLimit)
                }
                .onDelete(perform: confirmDelete)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Random Stories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: toolbar)
        .onTapGesture(count: 2, perform: model.update)
        .onOpenURL(perform: model.handleOpenURL)
        .storyImporter(isPresented: $model.showingFileImporter)
        .fileExporter(isPresented: $model.showingFileExporter, document: model.document, contentType: .json, onCompletion: model.handleFileExporter)
        .actionSheet(item: $actionSheetID, content: actionSheet)
        //.sheet(item: $model.sheetID, content: sheetView)
        //.sheet(item: $model.textsStruct, content: importSheetView)

    }
    
    
    
    private func importSheetView(textsStruct: RandomStoryListViewModel.TextsStruct) -> some View {
        ImportTextView(texts: textsStruct.texts)
            .environment(\.managedObjectContext, context)
    }
    

    
    private func sectionHeader() -> some View {
        model.stories.isEmpty ? Text("No Stories") : Text("Stories: \(model.stories.count)")
    }
    
    //  MARK: - Toolbar & Toolbar Items
    
    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading, content: leadingMenu)
        ToolbarItem(placement: .navigationBarTrailing, content: trailingMenu)
    }
    
    private func leadingMenu() -> some View {
        Menu {
            RandomListOptionsMenu()
        } label: {
            Label("List Options", systemImage: "slider.horizontal.3")
                .labelStyle(IconOnlyLabelStyle())
        }
        .if(model.listOptions.isActive) {
            $0.accentColor(Color(UIColor.systemOrange))
        }
    }
    
    private func trailingMenu() -> some View {
        Menu {
            RandomStoryListActions()
        } label: {
            Label("", systemImage: "ellipsis.circle")
                .labelStyle(IconOnlyLabelStyle())
        }
    }
    
    
    //  MARK: - Sheets
    
    @ViewBuilder
    private func sheetView(sheetID: RandomStoryListViewModel.SheetID) -> some View {
        Group {
            switch sheetID {
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
                    OLDSingleStoryViewWrapper(context: context)
                    
                case .importFile:
                    if let textsStruct = model.textsStruct,
                       let texts = textsStruct.texts {
                        ImportTextView(texts: texts)
                    } else {
                        Text("Error creating import sheet")
                    }

            }
        }
        .environment(\.managedObjectContext, context)
        .environmentObject(filter)
        .environmentObject(eventStore)
    }
    
    
    //  MARK: - Action Sheets
    
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
                // FIXME:
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


//  MARK: - Preview

struct RamdonStoryListView_Previews: PreviewProvider {
    @State static var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        Group {
            List {
                RandomStoryListActions()
            }
            .previewLayout(.fixed(width: 350, height: 500))
            
            RandomStoryListView()
                .preferredColorScheme(.dark)
        }
        .environment(\.sizeCategory, .extraLarge)
        .environment(\.managedObjectContext, context)
        .environmentObject(RandomStoryListViewModel(context: context))
        .environmentObject(Filter())
        .environmentObject(EventStore())
    }
}
