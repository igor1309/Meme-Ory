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
    
    @EnvironmentObject private var eventStore: EventStore
    
    /// used to pass to TagFilterView via filterButton
    @Binding var filter: Filter
    /// used to count
    private let fetchRequest: NSFetchRequest<Story>
    
    @FetchRequest private var stories: FetchedResults<Story>
    
    init(filter: Binding<Filter>) {
        _filter = filter
        fetchRequest = Story.fetchRequest(
            filter.wrappedValue.predicate,
            sortDescriptors: filter.wrappedValue.sortDescriptors
        )
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
    @State private var document = JSONDocument(data: "".data(using: .utf8)!)
    @State private var isImporting = false
    @State private var isExporting = false
    
    private var count: Int { context.realCount(for: fetchRequest) }
    
    var body: some View {
        List {
            TextField("Filter (at least 3 letters)", text: $filter.searchString)
                .searchModifier(text: $filter.searchString)
                .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            
            Section(header: Text("Stories: \(count)")) {
                ForEach(stories) { story in
                    StoryListRowView(story: story, filter: $filter, remindersAccessGranted: eventStore.accessGranted)
                }
                .onDelete(perform: confirmDeletion)
            }
        }
        .onOpenURL(perform: handleURL)
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [UTType.json], onCompletion: handleFileImport)
        .fileExporter(isPresented: $isExporting, document: document, contentType: .json, onCompletion: handlerFileExport)
        .onDisappear(perform: deleteTemporaryFile)
        .actionSheet(isPresented: $showConfirmation, content: confirmationActionSheet)
        .navigationBarItems(leading: optionsButton(), trailing: createImportExportButton())
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Stories")
        .sheet(isPresented: $showImportSheet, onDismiss: { importFileURL = nil }) {
            if let importFileURL = importFileURL {
                ImportBriefView(url: importFileURL)
                    .environment(\.managedObjectContext, context)
            } else {
                Text("Error getting import File URL.\n\(importFileURL?.getBriefs().map(\.text).joined() ?? "")")
                    .foregroundColor(.red)
            }
        }
    }
    
    private func handleURL(_ url: URL) {
        //  MARK: - FINISH THIS
        //  check url if it's json file - proceed
        importFileURL = url
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            withAnimation {
                showImportSheet = true
            }
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
                guard let export = stories.export() else { return }
                
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
            //                .imageScale(.large)
            //                .foregroundColor(Color(UIColor.systemBlue))
        }
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
        if filter.isActive {
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
                .padding([.vertical, .trailing])
        }
        .accentColor(optionsButtonColor)
        .sheet(isPresented: $showListOptions) {
            ListOptionView(filter: $filter)
                .environment(\.managedObjectContext, context)
        }
        .contextMenu {
            /// change item to sort by
            changeItemToSortByButton()
            /// toggle sort order
            sortOrderButton()
            /// set list limit (number of stories showing)
            Section {
                listLimitButton()
            }
            Section {
                /// filter by favorites
                filterByFavoritesButton()
                /// filter by reminders
                filterByRemindersButton()
            }
            /// reset filter by tag(s)
            resetFilterByTagSection()
        }
    }
    
    @ViewBuilder
    private func changeItemToSortByButton() -> some View {
        Button {
            //  MARK: - FINISH THIS
            //
            switch filter.itemToSortBy {
                case .timestamp: filter.itemToSortBy = .text
                case .text:      filter.itemToSortBy = .timestamp
            }
        } label: {
            Label(filter.itemToSortBy == .timestamp ? "Sort by Text" : "Sort by Date",
                  systemImage: filter.itemToSortBy == .timestamp ? "text.cursor" : "calendar")
        }
    }
    
    private func sortOrderButton() -> some View {
        Button {
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                filter.areInIncreasingOrder.toggle()
            }
        } label: {
            Label("Sort \(filter.areInIncreasingOrder ? "Descending": "Ascending")", systemImage: filter.areInIncreasingOrder ? "textformat" : "textformat.size")
        }
    }
    
    private func listLimitButton() -> some View {
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
    
    private func filterByFavoritesButton() -> some View {
        Button {
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                switch filter.favoritesFilter {
                    case .all:
                        filter.favoritesFilter = .fav
                    default:
                        filter.favoritesFilter = .all
                }
            }
        } label: {
            Label(filter.favoritesFilter == .all ? "Show Favorites" : "Show all", systemImage: "star.circle")
        }
    }
    
    private func filterByRemindersButton() -> some View {
        Button {
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                switch filter.remindersFilter {
                    case .all:
                        filter.remindersFilter = .have
                    default:
                        filter.remindersFilter = .all
                }
            }
        } label: {
            Label(filter.remindersFilter == .all ? "Show with Reminders" : "Show All", systemImage: "bell.circle")
        }
    }
    
    @ViewBuilder
    private func resetFilterByTagSection() -> some View {
        if filter.isTagFilterActive {
            Section {
                Button {
                    let haptics = Haptics()
                    haptics.feedback()
                    
                    withAnimation {
                        filter.reset()
                    }
                } label: {
                    Label("Reset Tags", systemImage: "tag.slash.fill")
                }
            }
        } else {
            EmptyView()
        }
    }
    
    private func createImportExportButton() -> some View {
        Button {
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                showCreateSheet = true
            }
        } label: {
            Image(systemName: "doc.badge.ellipsis")
                .padding([.leading, .vertical])
        }
        .sheet(isPresented: $showCreateSheet) {
            StoryEditorView()
                .environment(\.managedObjectContext, context)
        }
        .contextMenu {
            Section {
                importFileButton()
            }
            exportFileButton()
            shareButton()
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
    
    @State private var showImportSheet = false
    @State private var importFileURL: URL?
    
    private func handleFileImport(_ result: Result<URL, Error>) {
        switch result {
            case .success:
                guard let fileURL: URL = try? result.get() else { return }
                
                importFileURL = fileURL
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
                    withAnimation {
                        showImportSheet = true
                    }
                }
            case .failure(let error):
                print("Export error \(error.localizedDescription)")
        }
    }
    
    /// export Stories to JSON File
    private func exportFileButton() -> some View {
        Button {
            DispatchQueue.global(qos: .userInitiated).async {
                isExporting = false
                
                guard let data = stories.export() else {
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
}

fileprivate struct StoryListView_Testing: View {
    @State var filter = Filter()
    
    var body: some View {
        StoryListView(filter: $filter)
    }
}

struct StoryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StoryListView_Testing()
        }
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .environmentObject(EventStore())
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 350, height: 800))
    }
}
