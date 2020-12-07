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
           eventStore.accessGranted,
           let storyToEdit = storyToEdit {
            // if story has a pointer to the  reminder but reminder was deleted, clear the pointer in story and draft
            let reminder = eventStore.reminder(for: storyToEdit)
            if storyToEdit.calendarItemIdentifier != "" && reminder == nil {
                // this cleanup would be saved now, so pretend no changes were made here:
                // store and re-apply hasChanges value with little delay
                // to let publishers finish first
                let hasChanges = self.hasChanges
                
                storyToEdit.calendarItemIdentifier_ = nil
                calendarItemIdentifier = ""
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.hasChanges = hasChanges
                }
                
                context.saveContext()
            }
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
            }
            
            story.text                   = self.text
            story.tags                   = Array(self.tags)
            story.isFavorite             = self.isFavorite
            story.calendarItemIdentifier = self.calendarItemIdentifier
            
            context.saveContext()
            
            //            presentation.wrappedValue.dismiss()
        }
    }
}
