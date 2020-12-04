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
    
    @Published var storyURL: URL?
    
    @Published private(set) var story: Story?
    
    @Published var tags = Set<Tag>()
    
    @Published var title = "no such story"
    
    var tagNames: String {
        //story?.tags.map { $0.name }.joined(separator: ", ") ?? ""
        tags.map { $0.name }.joined(separator: ", ")
    }
    
    private let context: NSManagedObjectContext
    
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
                self?.story = $0
                self?.tags = Set($0.tags)
            }
            .store(in: &cancellables)
        
        $tags
            .map {
                Array($0).sorted()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.story?.tags = $0
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellables {
            cancell.cancel()
        }
    }
    
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
    
    func getRandomStory(noHapticsAndAnimation: Bool = false) {
        var random = Story.oneRandom(in: context)
        while random?.text == story?.text {
            random = Story.oneRandom(in: context)
        }
        
        let url = random?.url
        print("model: getRandomStory \(url?.absoluteString ?? "nil")")
        
        if noHapticsAndAnimation {
            storyURL = url
        } else {
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                storyURL = url
            }
        }
    }
    
    func deleteStory() {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            if let story = story {
                context.delete(story)
                context.saveContext()
                
                title = "Story was deleted"
            }
        }
    }
}
