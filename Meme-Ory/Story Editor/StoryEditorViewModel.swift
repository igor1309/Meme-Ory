//
//  StoryEditorViewModel.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 29.11.2020.
//

import SwiftUI
import Combine
import CoreData

final class StoryEditorViewModel: ObservableObject {
    @Published var text: String
    @Published var tags: Set<Tag>
    @Published var isFavorite: Bool
    @Published var calendarItemIdentifier: String
    @Published var mode: Mode
    
    @Published var hasChanges: Bool = false
    
    let storyToEdit: Story?
    
    enum Mode {
        case create, edit
        
        var title: String {
            switch self {
                case .edit:
                    return ""
                case .create:
                    return "New"
            }
        }
    }
    
    init() {
        text = ""
        tags = []
        isFavorite = false
        calendarItemIdentifier = ""
        mode = .create
        storyToEdit = nil
        
        subscribeToChanges()
    }
    
    init(story: Story) {
        self.text = story.text
        self.tags = Set(story.tags)
        self.isFavorite = story.isFavorite
        self.calendarItemIdentifier = story.calendarItemIdentifier
        self.mode = .edit
        storyToEdit = story
        
        subscribeToChanges()
    }
    
    private func subscribeToChanges() {
        Publishers.CombineLatest(
            Publishers.CombineLatest(
                $text,
                $tags
            ),
            Publishers.CombineLatest3(
                $mode,
                $isFavorite,
                $calendarItemIdentifier
            )
        )
        .dropFirst()
        .throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            print("StoryEditorViewModel: model changed")
            self?.hasChanges = true
        }
        .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellables {
            cancell.cancel()
        }
    }
    
    
    //  MARK: Functions
    
    func reminderCleanUp(eventStore: EventStore, context: NSManagedObjectContext) {
        //  reminder could be deleted from Reminders but Story still store reference (calendarItemIdentifier)
        if mode == .edit,
           let storyToEdit = storyToEdit {
            storyToEdit.reminderCleanUp(eventStore: eventStore, context: context)
        }
    }
    
    func saveStory(in context: NSManagedObjectContext) {
        Ory.withHapticsAndAnimation {
            let story: Story
            
            if let storyToEdit = self.storyToEdit {
                /// editing here
                story = storyToEdit
                story.objectWillChange.send()
            } else {
                /// create new story
                story = Story(context: context)
                story.timestamp = Date()
                let center = NotificationCenter.default
                center.post(name: .NewStoryCreated, object: story.url)
            }
            
            story.text                   = self.text
            story.tags                   = Array(self.tags)
            story.isFavorite             = self.isFavorite
            story.calendarItemIdentifier = self.calendarItemIdentifier
            
            context.saveContext()
        }
    }
}

extension Notification.Name {
    public static let NewStoryCreated = Notification.Name("NewStoryCreated")
}
