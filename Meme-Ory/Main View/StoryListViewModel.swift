//
//  MainViewViewModel.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 13.12.2020.
//

import SwiftUI
import CoreData

final class MainViewViewModel: ObservableObject {
    
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
        var lineLimit: Int {
            switch self {
                case .list: return 3
                case .randomStory: return 12
                case .widgetStory: return 12
            }
        }
     }
    
    
    //  MARK: - View Mode
    
    @Published var viewMode: ViewMode = .single
    
    enum ViewMode { case single, list }
    

    //  MARK: - Request
    
    @Published private var predicate: NSPredicate
    @Published private var sortDescriptors: [NSSortDescriptor]
    
    var request: NSFetchRequest<Story> {
        Story.fetchRequest(predicate, sortDescriptors: sortDescriptors)
    }
    
    
    //  MARK: - Handle URLs and Sheets
    
    @Published var sheetID: SheetID?
    
    enum SheetID: Identifiable {
        case new, maintenance
        case story(_ url: URL)
        case file(_ url: URL)
        
        var id: Int {
            switch self {
                case .new:            return "new".hashValue
                case .maintenance:    return "maintenance".hashValue
                case let .story(url): return url.hashValue
                case let .file(url):  return url.hashValue
            }
        }
    }
    

    //  MARK: - Internals
    
    private let context: NSManagedObjectContext
    
    //  MARK: - Constants
    
    let maxLineLimit = 12
    

    //  MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        //  FIXME: FINISH THIS:
        predicate = NSPredicate.all
        sortDescriptors = []
        
        self.viewOptions = .list
        
    }
    
    
    //  MARK: - Testing
    
    func togglePredicate() {
        Ory.withHapticsAndAnimation {
            if self.predicate == .all {
                self.predicate = .none
                self.viewOptions = .randomStory
            } else {
                self.predicate = .all
                self.viewOptions = .list
            }
        }
    }
    
    
    //  MARK: - Handle URLs
    
    func handleURL(_ url: URL) {
        Ory.withHapticsAndAnimation {
            
            #if DEBUG
            print("MainViewViewModel: handleURL call: \(url)")
            #endif
            
            guard let deeplink = url.deeplink else {
                // FIXME: create enum for alerts
                //showingFailedImportAlert = true
                
                #if DEBUG
                print("MainViewViewModel: handleURL: deeplink error")
                #endif
                
                return
            }
            
            switch deeplink {
                case .home:
                    //  FIXME: - FINISH THIS: ANY FEEDBACK TO USER?
                    /// do nothing we are here
                    #if DEBUG
                    print("MainViewViewModel: handleURL: deeplink home")
                    #endif
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.viewOptions = .list
                    }
                    return
                    
                case let .story(url):
                    #if DEBUG
                    print("MainViewViewModel: handleURL: deeplink storyURL")
                    #endif
                    
                    guard let objectID = self.context.getObjectID(for: url) else {
                        #if DEBUG
                        print("MainViewViewModel: handleURL: can't find story for this URL")
                        #endif
                        
                        return
                    }
                    
                    //self.sheetID = SheetID.story(url)
                    
                    self.predicate = NSPredicate(format: "self == %@", objectID)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.viewOptions = .widgetStory
                    }
                    
                case let .file(url):
                    let texts = url.getTexts()
                    
                    #if DEBUG
                    print("MainViewViewModel: handleURL: file with text: \((texts.first ?? "no texts").prefix(30))...")
                    #endif
                    
                    self.sheetID = SheetID.file(url)
                    
                    // FIXME: temporary feedback:
                    self.predicate = .none
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.viewOptions = .list
                    }
                    
            }
        }
    }
    
    
    //  MARK: - Sheets
    
    func showMaintenance() {
        sheetID = .maintenance
    }
    
    
    //  MARK: - Add New Ctory
    
    func addStory() {
        //  FIXME: FINISH THIS: adding story via StoryEditorView does not update @FetchRequest in MainView!!!
        sheetID = .new
    }
    
    
    //  MARK: - Paste Clipboard to New Story
    
    func pasteToNewStory() {
        if UIPasteboard.general.hasStrings {
            Story.createStoryFromPasteboard(context: context)
            
            //  FIXME: FINISH THIS:
            //let storyURL = Story.last(in: context)?.url
        }
    }


    //  MARK: - <#comment#>
    
    func deleteTemporaryFile() {
        //  FIXME: FINISH THIS:
    }
}
