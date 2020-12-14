//
//  RandomStoryListViewModel.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 08.12.2020.
//

import SwiftUI
import Combine
import CoreData

final class RandomStoryListViewModel: ObservableObject {
    
    @Published var k = 3
    
    @Published private(set) var stories = [Story]()
    
    @Published private(set) var title = "no such story"
    
    @Published private var storyURL: URL?
    
    @Published var lineLimit: Int? = nil
    
    @Published var listOptions = ListOptions()
    
    @Published var listType = ListType.random
    
    enum ListType: String, CaseIterable {
        case random, ordered
    }
    
    private let context: NSManagedObjectContext
    
    private let refreshRandom = PassthroughSubject<Void, Never>()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        subscribe()
    }
    
    private func subscribe() {
        /// if listOptions change list is ordered
        $listOptions
            .compactMap { [weak self] options in
                let request = options.fetchRequest
                let fetch = try? self?.context.fetch(request)
                return fetch
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (stories: [Story]) in
                self?.stories = stories
                self?.listType = .ordered
            }
            .store(in: &cancellableSet)
        
        /// sunscribe to change in k (number of stories) or requests for update (fresh random stories)
        Publishers.CombineLatest($k, refreshRandom)
            .map { (k, _) in
                self.context.randomObjects(k, ofType: Story.self)
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stories in
                self?.stories = stories
                self?.listType = .random
            }
            .store(in: &cancellableSet)
        
        /// observe inserting new stories into context: show inserted
        NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)
            .compactMap { notification in
                let context = notification.object as? NSManagedObjectContext
                guard context == self.context else { return nil }
                
                guard let insertedStories = notification.userInfo?[NSInsertedObjectsKey] as? Set<Story>,
                      !insertedStories.isEmpty else { return nil }
                
                return Array(insertedStories)
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stories in
                self?.stories = stories
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
    
    
    //  MARK: - Functions
    
    func update() {
        Ory.withHapticsAndAnimation {
            self.refreshRandom.send()
        }
    }
    
    func resetTags() {
        listOptions.resetTags()
    }
    
    
    //  MARK: Handle OpenURL
    
    @Published var textsStruct: TextsStruct?
    {
        didSet {
            print("self.sheetID = .importFile")
            self.sheetID = .importFile
    }}
    
    struct TextsStruct: Identifiable {
        let texts: [String]
        var id: Int { texts.hashValue }
    }
    
    let maxLineLimit = 12
    
    func handleOpenURL(url: URL) {
        Ory.feedback()
        
        guard let deeplink = url.deeplink else {
            // FIXME: create enum for alerts
            //showingFailedImportAlert = true
            
            #if DEBUG
            print("RandomStoryListViewModel: handleOpenURL: deeplink error")
            #endif
            
            return
        }
        
        switch deeplink {
            case .home:
                //  FIXME: - FINISH THIS: ANY FEEDBACK TO USER?
                /// do nothing we are here
                #if DEBUG
                print("RandomStoryListViewModel: handleOpenURL: deeplink home")
                #endif
                
                return
                
            case let .story(url):
                // storyURL = url
                #if DEBUG
                print("RandomStoryListViewModel: handleOpenURL: deeplink storyURL")
                #endif
                
                /// subscribe to valid story URLs called by onOpenURL
                // FIXME: CHANGE SUBCRIPTIONS!!!???
                
                if let story = context.getObject(with: url) as? Story {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    
                    self.stories = [story]
                    /// wil show one story so no line limit
                        self.lineLimit = self.maxLineLimit
                        
                    }
                    
                    
                    
                } else {
                    self.title = "no such story"
                    #if DEBUG
                    print("RandomStoryListViewModel: handleOpenURL: NO STORY for this deeplink storyURL")
                    #endif
                }
                
            case let .file(url):
                withAnimation {
                    let texts = url.getTexts()
                    
                    #if DEBUG
                    print("RandomStoryListViewModel: handleOpenURL: file with text: \((texts.first ?? "no texts").prefix(30))...")
                    #endif
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        

                    self.textsStruct = TextsStruct(texts: texts)
                    //self.sheetID = .importFile
                        
                    }
                        
                }
        }
    }
    
    
    //  MARK: Delete rows
    
    func delete(at indexSet: IndexSet) {
        for index in indexSet {
            context.delete(stories[index])
            context.saveContext()
        }
        
        update()
    }
    
    
    //  MARK: - Import
    
    @Published var showingFileImporter = false
    
    func importFile() {
        showingFileImporter = true
    }
    
    
    //  MARK: - Export
    
    @Published var showingFileExporter = false
    
    var document = JSONDocument(data: "".data(using: .utf8)!)
    
    func exportFile() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = self.stories.exportTexts() else {
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
    
    func shareStories() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let export = self.stories.exportTexts() else { return }
            
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
    
    
    //  MARK: - Paste Clipboard to New Story
    
    func pasteToNewStory() {
        if UIPasteboard.general.hasStrings {
            Story.createStoryFromPasteboard(context: context)
            
            storyURL = Story.last(in: context)?.url
        }
    }
    
    
    //  MARK: - Show some Random Story
    
    func getRandomStory() {
        getRandomStory(hasHapticsAndAnimation: true)
    }
    
    func getRandomStory(hasHapticsAndAnimation: Bool) {
        listType = .random
        
        let random = context.randomObject(ofType: Story.self)
        let url = random?.url
        
        if hasHapticsAndAnimation {
            Ory.withHapticsAndAnimation {
                self.storyURL = url
            }
        } else {
            storyURL = url
        }
    }
    
    
    
    //  MARK: - Sheets
    
    @Published var sheetID: SheetID?
    
    enum SheetID: Identifiable {
        case listOptions, tags, edit, new, maintenance, singleStoryUI, importFile
        var id: Int { hashValue }
    }
    
    func createNewStory() {
        // Ory.withHapticsAndAnimation {
        self.sheetID = .new
        // }
    }
    
    func showListOptions() {
        self.sheetID = .listOptions
    }
    
    
}
