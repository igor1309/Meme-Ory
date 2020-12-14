//
//  MainViewModel.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 13.12.2020.
//

import SwiftUI
import CoreData
import Combine

final class MainViewModel: ObservableObject {
    
    //  MARK: - View Options
    
    @Published private(set) var viewOptions: ViewOptions
    
    enum ViewOptions {
        case list, randomStory, widgetStory
        
        var title: String {
            switch self {
                case .list:        return "Stories"
                case .randomStory: return "Random Story"
                case .widgetStory: return "Story from Widget"
            }
        }
        var font: Font {
            switch self {
                case .list:        return .subheadline
                case .randomStory: return .body
                case .widgetStory: return .body
            }
        }
        var isList: Bool {
            switch self {
                case .list: return true
                default:    return false
            }
        }
    }
    
    
    //  MARK: - View Mode
    
    @Published var viewMode: ViewMode
    
    enum ViewMode: String, CaseIterable {
        case single, list
    }
    
    
    @Published var listOptions: ListOptions

    //  MARK: - Request
    
    @Published private(set) var request: NSFetchRequest<Story>
    
    
    //  MARK: - Handle URLs and Sheets
    
    @Published var sheetID: SheetID?
    
    enum SheetID {
        case new, edit, tags, maintenance, listOptions
        case story(_ url: URL)
        case file(_ url: URL)
    }
    
    
    @Published var actionSheetID: ActionSheetID?
    
    enum ActionSheetID: Identifiable {
        case delete, remindMe
        var id: Int { hashValue }
    }
    
    //  MARK: - Internals
    
    private let context: NSManagedObjectContext
    
    //  MARK: - Constants
    
    let maxLineLimit = 12
    
    
    //  MARK: - Init
    
    init(context: NSManagedObjectContext, viewMode: ViewMode = .list) {
        self.context = context
        self.viewOptions = .randomStory
        self.viewMode = viewMode
        self.listOptions = ListOptions()
        
        //  FIXME: FINISH THIS:
        self.request = {
            let predicate = NSPredicate.all
            let request = Story.fetchRequest(predicate)
            request.fetchLimit = 12
            return request
        }()
        
        
        /// subscribe to change view mode `to list` - reset predicate to filter
        //  FIXME: FINISH THIS:
        $viewMode
            .compactMap { mode -> Bool? in
                switch mode {
                    case .single: return nil
                    case .list:   return true
                }
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    if let self = self {
                        self.request = self.listOptions.fetchRequest
                    }
                }
            }
            .store(in: &cancellableSet)
        
        // subscribe to changes in list options if mode is list
        $listOptions
            .sink { [weak self] listOptions in
                #if DEBUG
                print("MainViewModel: $listOptions subs: SINK")
                #endif
                
                guard self?.viewMode == .some(.list) else { return }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    if let self = self {
                        self.request = self.listOptions.fetchRequest
                        #if DEBUG
                        print("MainViewModel: $listOptions subs: REQUEST CHANGED")
                        #endif
                    }
                }
            }
            .store(in: &cancellableSet)
    }

    
    private var cancellableSet = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellableSet {
            cancell.cancel()
        }
        
        deleteTemporaryFile()
    }
    
    
    
    //  MARK: - Handle URLs
    
    func handleURL(_ url: URL) {
        Ory.withHapticsAndAnimation {
            
            #if DEBUG
            print("MainViewModel: handleURL call: \(url)")
            #endif
            
            guard let deeplink = url.deeplink else {
                // FIXME: create enum for alerts
                //showingFailedImportAlert = true
                
                #if DEBUG
                print("MainViewModel: handleURL: deeplink error")
                #endif
                
                return
            }
            
            switch deeplink {
                case .home:
                    self.handleHomeURL()
                    
                case let .story(url):
                    self.handleStoryURL(url)
                    
                    
                case let .file(url):
                    self.handleFileURL(url)
                    
            }
        }
    }
    
    private func handleHomeURL() {
        //  FIXME: - FINISH THIS: ANY FEEDBACK TO USER?
        /// do nothing we are here (??)
        #if DEBUG
        print("MainViewModel: handleURL: deeplink home")
        #endif
        
        //  FIXME: FINISH THIS: list? or not?
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.viewOptions = .list
        }
    }
    
    private func handleStoryURL(_ url: URL) {
        #if DEBUG
        print("MainViewModel: handleURL: deeplink storyURL")
        #endif
        
        guard let objectID = self.context.getObjectID(for: url) else {
            #if DEBUG
            print("MainViewModel: handleURL: can't find story for this URL")
            #endif
            
            return
        }
        
        self.request = {
            let predicate = NSPredicate(format: "self == %@", objectID)
            let sortDescriptors = [NSSortDescriptor]()
            let request = Story.fetchRequest(predicate, sortDescriptors: sortDescriptors)
            return request
        }()
        
        //  FIXME: FINISH THIS:
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.viewOptions = .widgetStory
        }
    }
    
    private func handleFileURL(_ url: URL) {
        let texts = url.getTexts()
        
        #if DEBUG
        print("MainViewModel: handleURL: file with text: \((texts.first ?? "no texts").prefix(30))...")
        #endif
        
        self.sheetID = SheetID.file(url)
        
        // FIXME: temporary feedback:
        //  FIXME: FINISH THIS: ANY REQUEST CHANGES NEEDED???
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.viewOptions = .list
        }
    }
    
    
    //  MARK: - Get Random Story
    
    func getRandomStory() {
        Ory.withHapticsAndAnimation {
            self.viewMode = .single
            
            guard let randomStory = self.context.randomObject(ofType: Story.self) else {
                #if DEBUG
                print("MainViewModel: getRandomStory: ERROR getting random story from context")
                #endif
                return
            }
            
            self.request = {
                let predicate = NSPredicate(format: "self == %@", randomStory)
                let sortDescriptors = [NSSortDescriptor]()
                let request = Story.fetchRequest(predicate, sortDescriptors: sortDescriptors)
                return request
            }()
        }
    }
    
    
    //  MARK: - Shuffle List
    
    func shuffleList() {
        //  FIXME: FINISH THIS:
        
    }
    
    
    //  MARK: - Reset Tags
    
    func resetTags() {
        listOptions.resetTags()
    }
    

    //  MARK: - Import
    
    @Published var showingFileImporter = false
    
    func importFile() {
        showingFileImporter = true
    }
    
    
    //  MARK: - Export
    
    @Published var showingFileExporter = false
    
    var document = JSONDocument(data: "".data(using: .utf8)!)
    
    func exportFile(stories: [Story]) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = stories.exportTexts() else {
                print("Error creating export from stories")
                return
            }
            
            self.document = JSONDocument(data: data)
            
            // fix broken picker sheet
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                withAnimation {
                    self.showingFileExporter = true
                }
            }
        }
    }
    
    func handleFileExporter(_ result: Result<URL, Error>) {
        switch result {
            case .success:
                print("Exported successfully.")
            case .failure(let error):
                print("Export error \(error.localizedDescription)")
        }
    }
    
    
    //  MARK: - Share Stories
    
    private var temporaryFileURL: URL?
    
    func deleteTemporaryFile() {
        guard let temporaryFileURL = temporaryFileURL else { return }
        
        do {
            try FileManager.default.removeItem(at: temporaryFileURL)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func shareStories(stories: [Story]) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let export = stories.exportTexts() else { return }
            
            /// set temporary file
            /// https://nshipster.com/temporary-files/
            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let temporaryFilename = "stories.json"//ProcessInfo().globallyUniqueString
            self.temporaryFileURL =
                temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
            
            /// write to temporary file
            guard let temporaryFileURL = self.temporaryFileURL, let _ = try? export.write(to: temporaryFileURL, options: .atomic) else { return }
            
            /// present share sheet
            let items = [temporaryFileURL]
            
            let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
                }
            }
        }
    }
    
    
    //  MARK: -Show Sheets: Create New Ctory, Story Editor, Story List & Tag Grid for Editing
    
    func showMaintenance() {
        sheetID = .maintenance
    }
    
    func createNewStory() {
        //  FIXME: FINISH THIS: adding story via StoryEditorView does not update @FetchRequest in MainView!!!
        sheetID = .new
    }
    
    var storyToEdit: Story?
    
    func showStoryEditor(story: Story) {
        Ory.withHapticsAndAnimation {
            self.storyToEdit = story
            self.sheetID = .edit
        }
    }
    
    func showStoryList() {
        Ory.withHapticsAndAnimation {
            //  FIXME: FINISH THIS:
            //self.sheetID = .list
        }
    }
    
    func showTagGrid(story: Story) {
        Ory.withHapticsAndAnimation {
            self.storyToEdit = story
            self.sheetID = .tags
        }
    }
    
    func showListOptions() {
        self.sheetID = .listOptions
    }
    

    //  MARK: Show Action Sheets: Delete Story & RemindMe
    
    func deleteStoryAction() {
        actionSheetID = .delete
    }
    
    func remindMeAction(story: Story) {
        Ory.withHapticsAndAnimation {
            self.storyToEdit = story
            self.actionSheetID = .remindMe
        }
    }
    
    
    //  MARK: - Paste Clipboard to New Story
    
    func pasteToNewStory() {
        if UIPasteboard.general.hasStrings {
            Story.createStoryFromPasteboard(context: context)
            
            //  FIXME: FINISH THIS:
            //let storyURL = Story.last(in: context)?.url
        }
    }
    
    
    //  MARK: Share Story Text
    
    func shareText(_ text: String) {
        let items = [text]
        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
    }
    
    
    //  MARK: - Switch View Mode
    
    func switchViewMode() {
        Ory.withHapticsAndAnimation {
            switch self.viewMode {
                case .single: self.viewMode = .list
                case .list:   self.viewMode = .single
            }
        }
    }
    
    
    //  MARK: - Delete Story
    
    func delete(story: Story) {
        // no animation - getRandomStory has it
        getRandomStory()
        
        context.delete(story)
        context.saveContext()
        
        //  FIXME: FINISH THIS:
        //self.title = "Story was deleted"
    }

}
