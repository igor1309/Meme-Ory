//
//  StoryListView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct StoryListView: View {
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject private var eventStore: EventStore
    
    @ObservedObject private var filter: Filter
    
    private let showPasteButton: Bool
    /// used to count
    private let fetchRequest: NSFetchRequest<Story>
    
    @FetchRequest private var stories: FetchedResults<Story>
    
    init(filter: Filter, showPasteButton: Bool = true) {
        self.filter = filter
        self.showPasteButton = showPasteButton
        
        fetchRequest = Story.fetchRequest(filter.predicate, sortDescriptors: filter.sortDescriptors)
        
        if filter.isListLimited {
            fetchRequest.fetchLimit = filter.listLimit
        }
        
        _stories = FetchRequest(fetchRequest: fetchRequest)
    }
    
    @State private var showingCreateNewStorySheet = false
    @State private var showingDeleteConfirmation = false
    @State private var showingImportTextView = false
    @State private var showingFailedImportAlert = false
    @State private var showingFileImporter = false
    @State private var showingFileExporter = false
    @State private var importFileURL: URL?
    @State private var temporaryFileURL: URL?
    @State private var offsets = IndexSet()
    @State private var document = JSONDocument(data: "".data(using: .utf8)!)
    
    private var count: Int { context.realCount(for: fetchRequest) }
    
    var body: some View {
        List {
            TextField("Filter (at least 3 letters)", text: $filter.searchString)
                .searchModifier(text: $filter.searchString)
            
            Section(header: Text("Stories: \(count)")) {
                ForEach(stories, content: StoryListRowView.init)
                    .onDelete(perform: confirmDeletion)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Stories")
        .navigationBarItems(leading: ListOptionsMenu(),
                            trailing: HStack {
                                importExportShareMenu()
                                if showPasteButton {
                                    createNewStoryButton()
                                }
                            })
        .onChange(of: scenePhase, perform: handleScenePhase)
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [UTType.json], onCompletion: handleFileImporter)
        .fileExporter(isPresented: $showingFileExporter, document: document, contentType: .json, onCompletion: handlerFileExporter)
        .actionSheet(isPresented: $showingDeleteConfirmation, content: confirmationActionSheet)
        .sheet(isPresented: $showingImportTextView, onDismiss: { importFileURL = nil }, content: importTextView)
        .alert(isPresented: $showingFailedImportAlert, content: failedImportAlert)
        .onDisappear(perform: onDisapperAction)
    }
    
    private func handleScenePhase(scenePhase: ScenePhase) {
        if scenePhase == .background {
            deleteTemporaryFile()
            context.saveContext()
        }
    }
    
    private func handleFileImporter(_ result: Result<URL, Error>) {
        switch result {
            case .success(let url):
                print("Import success")
                importFileURL = url
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        showingImportTextView = true
                    }
                }
            case .failure(let error):
                print("Import error \(error.localizedDescription)")
        }
    }
    
    private func onDisapperAction() {
        context.saveContext()
        deleteTemporaryFile()
    }
    
    private func deleteTemporaryFile() {
        guard let temporaryFileURL = temporaryFileURL else { return }
        
        do {
            try FileManager.default.removeItem(at: temporaryFileURL)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func confirmDeletion(offsets: IndexSet) {
        self.offsets = offsets
        showingDeleteConfirmation = true
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
    
    private func createNewStoryButton() -> some View {
        Button {
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                showingCreateNewStorySheet = true
            }
        } label: {
            Image(systemName: "doc.badge.ellipsis")
                .padding([.leading, .vertical])
        }
        .sheet(isPresented: $showingCreateNewStorySheet) {
            NavigationView {
                StoryEditorView()
            }
            .environment(\.managedObjectContext, context)
            .environmentObject(eventStore)
        }
    }
    
    private func importExportShareMenu() -> some View {
        Menu {
            Section {
                pasteClipboardToStoryButton()
                // PasteClipboardToStoryButton(action: {})
            }
            Section {
                shareButton()
            }
            Section {
                importFileButton().disabled(true)
                exportFileButton()
            }
        } label: {
            Label("Create New Import Export", systemImage: "ellipsis.circle")
                .labelStyle(IconOnlyLabelStyle())
        }
    }
    
    @ViewBuilder
    private func pasteClipboardToStoryButton() -> some View {
        // if clipboard has text paste and save story
        if UIPasteboard.general.hasStrings {
            Button {
                let haptics = Haptics()
                haptics.feedback()
                
                withAnimation {
                    if let content = UIPasteboard.general.string,
                       !content.isEmpty {
                        let story = Story(context: context)
                        story.text = content
                        story.timestamp = Date()
                        
                        context.saveContext()
                    }
                }
            } label: {
                Label("Paste to story", systemImage: "doc.on.clipboard")
            }
        }
    }
    
    /// export (share) JSON file via Share Sheet
    private func shareButton() -> some View {
        Button {
            DispatchQueue.global(qos: .userInitiated).async {
                guard let export = stories.exportTexts() else { return }
                
                /// set temporary file
                /// https://nshipster.com/temporary-files/
                let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                let temporaryFilename = "stories.json"//ProcessInfo().globallyUniqueString
                temporaryFileURL =
                    temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
                
                /// write to temporary file
                guard let temporaryFileURL = temporaryFileURL, let _ = try? export.write(to: temporaryFileURL, options: .atomic) else { return }
                
                /// present share sheet
                let items = [temporaryFileURL]
                
                let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
                    }
                }
            }
        } label: {
            Label("Share Stories", systemImage: "square.and.arrow.up")
            // .imageScale(.large)
            // .foregroundColor(Color(UIColor.systemBlue))
        }
    }
    
    /// import File with Stories
    private func importFileButton() -> some View {
        Button {
            // fix broken picker sheet
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                withAnimation {
                    showingFileImporter = true
                }
            }
        } label: {
            Label("Import File", systemImage: "arrow.down.doc.fill")
        }
    }
    
    /// export Stories to JSON File
    private func exportFileButton() -> some View {
        Button {
            DispatchQueue.global(qos: .userInitiated).async {
                guard let data = stories.exportTexts() else {
                    print("Error creating export from stories")
                    return
                }
                
                document = JSONDocument(data: data)
                
                // fix broken picker sheet
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                    withAnimation {
                        showingFileExporter = true
                    }
                }
            }
        } label: {
            Label("Export File", systemImage: "arrow.up.doc.fill")
        }
    }
    
    private func handlerFileExporter(_ result: Result<URL, Error>) {
        switch result {
            case .success:
                print("Exported successfully.")
            case .failure(let error):
                print("Export error \(error.localizedDescription)")
        }
    }
    
    
    //  MARK: Import File
    
    private func importTextView() -> some View {
        ImportTextView(url: importFileURL)
            .environment(\.managedObjectContext, context)
            .environmentObject(filter)
    }
    
    private func failedImportAlert() -> Alert {
        Alert(title: Text("Error"), message: Text("Can't process yuor request.\nSorry about that"), dismissButton: Alert.Button.cancel(Text("Ok")))
    }
}

fileprivate struct StoryListView_Testing: View {
    @StateObject private var filter = Filter()
    
    var body: some View {
        StoryListView(filter: filter)
    }
}

struct StoryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StoryListView_Testing()
        }
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .environmentObject(EventStore())
        .environmentObject(Filter())
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 350, height: 800))
    }
}
