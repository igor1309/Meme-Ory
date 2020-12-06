//
//  RandomStoryViewModel.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 04.12.2020.
//

import SwiftUI
import CoreData
import Combine

final class RandomStoryViewModel: ObservableObject {
    
    @Published private(set) var randomStory: Story?
    
    @Published private(set) var title = "no such story"
    
    @Published private var storyURL: URL?
    
    private let context: NSManagedObjectContext
    
    @Published var sheetIdentifier: SheetIdentifier?
    
    struct SheetIdentifier: Identifiable {
        var id: Modal
        enum Modal { case list, tags, edit }
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
        
        let haptics = Haptics()
        haptics.feedback()
        
        // withAnimation {
        storyURL = url
        // showingList = false
        // }
    }
    
    
    //  MARK: Show Story Editor
    
    func showStoryEditor() {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            sheetIdentifier = SheetIdentifier(id: .edit)
        }
    }
    
    
    //  MARK: Show Story List
    
    func showStoryList() {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            sheetIdentifier = SheetIdentifier(id: .list)
        }
    }
    
    
    //  MARK: Show Tag Grid for Editing
    
    func showTagGrid() {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            sheetIdentifier = SheetIdentifier(id: .tags)
        }
    }
    
    
    //  MARK: Paste clipboard to new story
    
    func pasteToNewStory() {
        if UIPasteboard.general.hasStrings,
           let content = UIPasteboard.general.string,
           !content.isEmpty {
            let story = Story(context: context)
            story.text = content
            story.timestamp = Date()
            
            context.saveContext()
            
            storyURL = Story.last(in: context)?.url
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
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                storyURL = url
            }
        } else {
            storyURL = url
        }
    }
    
    
    //  MARK: Delete currently shown Story
    
    func deleteStory() {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            if let story = randomStory {
                context.delete(story)
                context.saveContext()
                
                title = "Story was deleted"
            }
        }
    }
}
