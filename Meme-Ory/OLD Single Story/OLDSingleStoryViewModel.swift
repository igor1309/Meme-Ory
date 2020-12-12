//
//  OLDSingleStoryViewModel.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 04.12.2020.
//

import SwiftUI
import CoreData
import Combine

final class OLDSingleStoryViewModel: ObservableObject {
    
    @Published private(set) var randomStory: Story?
    
    @Published private(set) var title = "no such story"
    
    @Published private var storyURL: URL?
    
    private let context: NSManagedObjectContext
    
    @Published var sheetID: SheetID?
    
    enum SheetID: Identifiable {
        case list, tags, edit, new
        var id: Int { hashValue }
    }

    @Published var actionSheetID: ActionSheetID?
    
    enum ActionSheetID: Identifiable {
        case delete, remindMe
        var id: Int { hashValue }
    }

    init(context: NSManagedObjectContext) {
        self.context = context
        
        // subscriptions
        //
        $storyURL
            .compactMap {
                context.getObject(with: $0) as? Story
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.randomStory = $0
            }
            .store(in: &cancellables)
        
        $storyURL
            .filter { $0 == nil }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.title = "no such story"
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .NewStoryCreated)
            .compactMap { _ in
                Story.last(in: context)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.randomStory = $0
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellables {
            cancell.cancel()
        }
    }
    
    
    //  MARK: Handle OpenURL
    
    func handleOpenURL(url: URL) {
        guard case .story(_) = url.deeplink else { return }
        
        #if DEBUG
        //print("handleOpenURL: \(url)")
        #endif
        
        Ory.feedback()
        
        // animation here works bad
        // withAnimation {
        storyURL = url
        // showingList = false
        // }
    }
    
    
    //  MARK: Show Sheets: Story Editor, Story List & Tag Grid for Editing
    
    func showStoryEditor() {
        Ory.withHapticsAndAnimation {
            self.sheetID = .edit
        }
    }
    
    func showStoryList() {
        Ory.withHapticsAndAnimation {
            self.sheetID = .list
        }
    }

    func showTagGrid() {
        Ory.withHapticsAndAnimation {
            self.sheetID = .tags
        }
    }
    
    
    //  MARK: Show Action Sheets: Delete Story & RemindMe

    func deleteStoryAction() {
        actionSheetID = .delete
    }
    
    func remindMeAction() {
        actionSheetID = .remindMe
    }


    //  MARK: Paste clipboard to new story
    
    func pasteToNewStory() {
        if UIPasteboard.general.hasStrings {
            Story.createStoryFromPasteboard(context: context)
            
            storyURL = Story.last(in: context)?.url
        }
    }
    
    
    //  MARK: Create new Story
    
    func createNewStory() {
        Ory.withHapticsAndAnimation {
            self.sheetID = .new
        }
    }
    
    
    //  MARK: Show some random story
    
    func getRandomStory() {
        getRandomStory(hasHapticsAndAnimation: true)
    }
    
    func getRandomStory(hasHapticsAndAnimation: Bool) {
        let random = context.randomObject(ofType: Story.self)
        
        let url = random?.url
        //print("model: getRandomStory \(url?.absoluteString ?? "nil")")
        
        if hasHapticsAndAnimation {
            Ory.withHapticsAndAnimation {
                self.storyURL = url
            }
        } else {
            storyURL = url
        }
    }
    
    
    //  MARK: Delete currently shown Story
    
    func deleteStory() {
        Ory.withHapticsAndAnimation {
            if let story = self.randomStory {
                self.context.delete(story)
                self.context.saveContext()
                
                self.title = "Story was deleted"
            }
            
            self.getRandomStory()
        }
    }
}
