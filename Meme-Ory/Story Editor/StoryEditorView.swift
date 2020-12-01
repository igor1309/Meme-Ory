//
//  StoryEditorView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI
import EventKit

struct StoryEditorView: View {
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) private var presentation
    
    @EnvironmentObject private var eventStore: EventStore
    
    @StateObject private var model: StoryEditorViewModel
    
    private let storyToEdit: Story?
    
    // Create new Story
    init() {
        _model = StateObject(wrappedValue: StoryEditorViewModel())
        storyToEdit = nil
    }
    
    // Edit Existing Story
    init(story: Story) {
        let model = StoryEditorViewModel(text: story.text, tags: Set(story.tags), isFavorite: story.isFavorite, calendarItemIdentifier: story.calendarItemIdentifier)
        _model = StateObject(wrappedValue: model)
        storyToEdit = story
        
        /// TextEditor is backed by UITextView. Get rid of the UITextView's backgroundColor to set  background
        UITextView.appearance().backgroundColor = .clear
    }
    
    @State private var showingMessage = false
    @State private var message = ""
    
    private var hasReminder: Bool { eventStore.hasReminder(with: model.calendarItemIdentifier) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextEditor(text: $model.text)
                .onAppear(perform: pasteClipboard)
                .padding([.horizontal, .top])
                .background(Color.clear)
            
            Divider().padding(.bottom, 6)
            
            HStack(alignment: .top) {
                StoryTagView(tags: $model.tags)
                    .padding(.leading)
                
                toggleReminderButton()
                toggleFavoriteButton()
                //  MARK: share button not working with presented sheet!
                shareButton()
            }
            .padding(.trailing)
        }
        .background(textBackground)
        .navigationBarTitle(model.mode.title, displayMode: .inline)
        .navigationBarItems(leading: cancelButton(), trailing: saveButton())
        .actionSheet(isPresented: $showingMessage, content: { ActionSheet(title: Text(message), buttons: []) })
        .onAppear(perform: reminderCleanUp)
    }
    
    @ViewBuilder
    private var textBackground: some View {
        if model.mode == .edit {
            Color(UIColor.secondarySystemGroupedBackground).edgesIgnoringSafeArea(.all)
        } else {
            Color.clear
        }
    }
    
    private func pasteClipboard() {
        withAnimation {
            /// if editing try to paste clipboard content
            if model.mode == .create {
                if UIPasteboard.general.hasStrings,
                   let content = UIPasteboard.general.string,
                   !content.isEmpty {
                    model.text = content
                }
            }
        }
    }
    
    private func reminderCleanUp() {
        //  reminder could be deleted from Reminders but Story still store reference (calendarItemIdentifier)
        if model.mode == .edit,
           eventStore.accessGranted,
           let storyToEdit = storyToEdit {
            // if story has a pointer to the  reminder but reminder was deleted, clear the pointer in story and draft
            let reminder = eventStore.reminder(for: storyToEdit)
            if storyToEdit.calendarItemIdentifier != "" && reminder == nil {
                // this cleanup would be saved now, so pretend no changes were made here:
                // store and re-apply hasChanges value with little delay
                // to let publishers finish first
                let hasChanges = model.hasChanges
                
                storyToEdit.calendarItemIdentifier_ = nil
                model.calendarItemIdentifier = ""
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    model.hasChanges = hasChanges
                }
                
                context.saveContext()
            }
        }
    }
    
    private func shareButton() -> some View {
        Button {
            let items = [model.text]
            let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
        } label: {
            Image(systemName: "square.and.arrow.up")
                .imageScale(.large)
                .frame(width: 44, height: 32)
        }
    }
    
    private func toggleReminderButton() -> some View {
        Button(action: toggleReminder) {
            Image(systemName: hasReminder ? "bell.fill" : "bell")
                .foregroundColor(hasReminder ? Color(UIColor.systemOrange) : .accentColor)
                .imageScale(.large)
                .frame(width: 44, height: 32)
        }
    }
    
    private func toggleReminder() {
        withAnimation {
            if hasReminder {
                // delete reminder
                eventStore.deleteReminder(withIdentifier: model.calendarItemIdentifier)
                model.calendarItemIdentifier = ""
                
                temporaryMessage("Reminder was deleted".uppercased())
            } else {
                //  MARK: - FINISH THIS ADD REMINDER
                temporaryMessage("\("Cannot add reminder here".uppercased())\nPlease use Context Menu for row in Stories List.", seconds: 4)
            }
        }
    }
    
    private func temporaryMessage(_ message: String, seconds: Int = 2) {
        self.message = message
        showingMessage = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds)) {
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                showingMessage = false
                self.message = ""
            }
        }
    }
    
    private func toggleFavoriteButton() -> some View {
        Button {
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                model.isFavorite.toggle()
            }
        } label: {
            Image(systemName: model.isFavorite ? "star.fill" : "star")
                .foregroundColor(model.isFavorite ? Color(UIColor.systemOrange) : .accentColor)
                .imageScale(.large)
                .frame(width: 44, height: 32)
        }
    }
    
    @ViewBuilder
    private func cancelButton() -> some View {
        if model.mode == .create {
            Button("Cancel") {
                presentation.wrappedValue.dismiss()
            }
        }
    }
    
    private func saveButton() -> some View {
        Button(model.hasChanges ? "Save" : "Done") {
            saveStory()
        }
        .foregroundColor(model.hasChanges ? .orange : .clear)
        .disabled(model.text.isEmpty)
    }
    
    private func saveStory() {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            let story: Story
            
            if let storyToEdit = storyToEdit {
                /// editing here
                story = storyToEdit
                story.objectWillChange.send()
            } else {
                /// create new story
                story = Story(context: context)
                story.timestamp = Date()
            }
            
            story.text                   = model.text
            story.tags                   = Array(model.tags)
            story.isFavorite             = model.isFavorite
            story.calendarItemIdentifier = model.calendarItemIdentifier
            
            context.saveContext()
            
            presentation.wrappedValue.dismiss()
        }
    }
}

struct StoryEditorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StoryEditorView()
                .previewLayout(.fixed(width: 350, height: 300))
            StoryEditorView(story: SampleData.story(storyIndex: 10, tagIndex: 3))
            //                .previewLayout(.fixed(width: 350, height: 400))
        }
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .environmentObject(EventStore())
        .preferredColorScheme(.dark)
    }
}
