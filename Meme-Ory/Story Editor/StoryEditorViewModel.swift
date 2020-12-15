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
        .subscribe(on: DispatchQueue.global())
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            //print("StoryEditorViewModel: model changed")
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
    
    func pasteClipboard() {
        Ory.withHapticsAndAnimation {
            /// if editing try to paste clipboard content
            if self.mode == .create {
                guard let content = UIPasteboard.general.string else { return }
                
                let clean = content.trimmed()
                if !clean.isEmpty {
                    self.text = content
                }
            }
        }
    }
    
    func toggleReminder(eventStore: EventStore) {
        Ory.withHapticsAndAnimation {
            if let storyToEdit = self.storyToEdit,
               storyToEdit.hasReminder {
                // delete reminder
                eventStore.deleteReminder(withIdentifier: self.calendarItemIdentifier)
                storyToEdit.calendarItemIdentifier = ""
                self.calendarItemIdentifier = ""
                
                self.temporaryMessage("Reminder was deleted".uppercased())
            } else {
                //  MARK: - FINISH THIS ADD REMINDER
                self.temporaryMessage("\("Cannot add reminder here".uppercased())\nPlease use Context Menu for row in Stories List.", seconds: 4)
            }
        }
    }
    
    @Published var showingMessage = false
    @Published var message = ""
    func temporaryMessage(_ message: String, seconds: Int = 2) {
        Ory.withHapticsAndAnimation {
            self.message = message
            self.showingMessage = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds)) {
                self.showingMessage = false
                self.message = ""
            }
        }
    }
    
    func reminderCleanUp(eventStore: EventStore, context: NSManagedObjectContext) {
        //  reminder could be deleted from Reminders but Story still store reference (calendarItemIdentifier)
        if mode == .edit,
           let storyToEdit = storyToEdit {
            eventStore.reminderCleanup(for: storyToEdit, in: context)
        }
    }
    
    func shareStoryText() {
        let items = [text]
        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
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
            
            story.text =                   self.text.trimmed()
            story.tags =                   Array(self.tags)
            story.isFavorite =             self.isFavorite
            story.calendarItemIdentifier = self.calendarItemIdentifier
            
            context.saveContext()
        }
    }
}

