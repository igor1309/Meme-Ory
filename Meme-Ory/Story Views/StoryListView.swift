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
    
    let quickActionPublisher = NotificationCenter.default.publisher(for: Notification.Name("QuickAction"))
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject private var eventStore: EventStore
    
    @ObservedObject private var filter: Filter
    
    /// used to count
    private let fetchRequest: NSFetchRequest<Story>
    
    @FetchRequest private var stories: FetchedResults<Story>
    
    init(filter: Filter) {
        self.filter = filter
        
        fetchRequest = Story.fetchRequest(
            filter.predicate,
            sortDescriptors: filter.sortDescriptors
        )
        
        if filter.isListLimited {
            fetchRequest.fetchLimit = filter.listLimit
        }
        
        _stories = FetchRequest(fetchRequest: fetchRequest)
    }
    
    @State private var showingCreateSheet = false
    @State private var showingConfirmation = false
    @State private var showImportTextView = false
    @State private var isImporting = false
    @State private var isExporting = false
    @State private var importFileURL: URL?
    @State private var offsets = IndexSet()
    @State private var document = JSONDocument(data: "".data(using: .utf8)!)
    
    @State private var storyToShowURL = URL(string: "https://www.apple.com")!
    
    private var count: Int { context.realCount(for: fetchRequest) }
    
    var body: some View {
        List {
            TextField("Filter (at least 3 letters)", text: $filter.searchString)
                .searchModifier(text: $filter.searchString)
            
            Section(header: Text("Stories: \(count)")) {
                ForEach(stories) { story in
                    StoryListRowView(story: story)
                        .environment(\.storyToShowURL, storyToShowURL)
                }
                .onDelete(perform: confirmDeletion)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Stories")
        .navigationBarItems(leading: ListOptionsMenu(),
                            trailing: HStack {
                                importExportShareMenu()
                                createNewStoryButton()
                            })
        .onReceive(quickActionPublisher, perform: handleQuickAction)
        .onChange(of: scenePhase, perform: handleScenePhase)
        .onOpenURL(perform: handleURL)
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [UTType.json], onCompletion: handleFileImport)
        .fileExporter(isPresented: $isExporting, document: document, contentType: .json, onCompletion: handlerFileExport)
        .onDisappear(perform: deleteTemporaryFile)
        .actionSheet(isPresented: $showingConfirmation, content: confirmationActionSheet)
        .sheet(isPresented: $showImportTextView, onDismiss: { importFileURL = nil }, content: importTextView)
        .alert(isPresented: $showingCannotImportAlert, content: failedImportAlert)
    }
    
    private func handleQuickAction(_ output: NotificationCenter.Publisher.Output) {
        let actionType = output.userInfo?["actionType"] as! String
        if let quickAction = QuickAction(rawValue: actionType) {
            switch quickAction {
                case .pasteToNew:
                    showingCreateSheet = true
                case .showFavorites:
                    filter.favoritesFilter = .fav
            }
        }
    }
    
    private func handleScenePhase(scenePhase: ScenePhase) {
        if scenePhase == .background {
            deleteTemporaryFile()
        }
    }
    
    private func handleURL(_ url: URL) {
        showingCannotImportAlert = false
        showImportTextView = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            
            let deeplinker = Deeplinker()
            guard let deeplink = deeplinker.manage(url: url) else {
                showingCannotImportAlert = true
                return
            }
            
            switch deeplink {
                case .home:
                    //  MARK: - FINISH THIS ANY FEEDBACK TO USER?
                    /// do nothing we are here
                    return
                case let .story(reference):
                    //  MARK: - FINISH THIS
                    // WHAT TO DO HERE? PASS TO ROW???
                    print(reference)
                    //environment(\.storyToShowURL, reference)
                    storyToShowURL = reference
                case let .file(url):
                    self.importFileURL = url
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                        withAnimation {
                            showImportTextView = true
                        }
                    }
            }
        }
    }
    
    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
            case .success:
                guard let fileURL: URL = try? result.get() else { return }
                
                importFileURL = fileURL
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                    withAnimation {
                        showImportTextView = true
                    }
                }
            case .failure(let error):
                print("Export error \(error.localizedDescription)")
        }
    }
    
    @State private var temporaryFileURL: URL?
    
    private func deleteTemporaryFile() {
        guard let temporaryFileURL = temporaryFileURL else { return }
        
        do {
            try FileManager.default.removeItem(at: temporaryFileURL)
        } catch let error as NSError {
            print(error.localizedDescription)
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
                
                DispatchQueue.main.async {
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
    
    private func confirmDeletion(offsets: IndexSet) {
        self.offsets = offsets
        showingConfirmation = true
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
                showingCreateSheet = true
            }
        } label: {
            Image(systemName: "doc.badge.ellipsis")
                .padding([.leading, .vertical])
        }
        .sheet(isPresented: $showingCreateSheet) {
            StoryEditorView()
                .environment(\.managedObjectContext, context)
                .environmentObject(eventStore)
        }
    }
    
    private func importExportShareMenu() -> some View {
        Menu {
            shareButton()
            Section {
                importFileButton()
                exportFileButton()
            }
        } label: {
            Label("Create New Import Export", systemImage: "ellipsis.circle")
                .labelStyle(IconOnlyLabelStyle())
        }
    }
    
    /// import File with Stories
    private func importFileButton() -> some View {
        Button {
            isImporting = false
            
            //fix broken picker sheet
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                withAnimation {
                    isImporting = true
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
                isExporting = false
                
                guard let data = stories.exportTexts() else {
                    print("Error creating export from stories")
                    return
                }
                
                document = JSONDocument(data: data)
                
                //fix broken picker sheet
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                    withAnimation {
                        isExporting = true
                    }
                }
            }
        } label: {
            Label("Export File", systemImage: "arrow.up.doc.fill")
        }
    }
    
    private func handlerFileExport(_ result: Result<URL, Error>) {
        switch result {
            case .success:
                print("Exported successfully.")
            case .failure(let error):
                print("Export error \(error.localizedDescription)")
        }
    }
    
    @ViewBuilder
    private func importTextView() -> some View {
        if let importFileURL = importFileURL {
            ImportTextView(url: importFileURL)
                .environment(\.managedObjectContext, context)
                .environmentObject(filter)
        } else {
            ErrorSheet(message: "Error getting Import File URL\nPlease try again") {
                Button("Try again") {
                    showImportTextView = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
                        withAnimation {
                            showImportTextView = true
                        }
                    }
                }
            }
        }
    }
    
    @State private var showingCannotImportAlert = false
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
