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
    private let title: String
    private let calendarItemIdentifier: String
    
    /// Create new Story
    init() {
        _model = StateObject(wrappedValue: StoryEditorViewModel())
        storyToEdit = nil
        title = "New"
        calendarItemIdentifier = ""
    }
    
    /// Edit Existing Story
    init(story: Story, remindersAccessGranted: Bool) {
        let model = StoryEditorViewModel(text: story.text, tags: Set(story.tags), isFavorite: story.isFavorite)
        _model = StateObject(wrappedValue: model)
        storyToEdit = story
        title = ""
        calendarItemIdentifier = story.calendarItemIdentifier
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading) {
                    TextEditor(text: $model.text)
                        .onAppear(perform: pasteClipboard)
                    
                    HStack(alignment: .top) {
                        StoryTagView(tags: $model.tags)
                        
                        toggleFavoriteButton()
                        
                        //  MARK: share button not working with presented sheet!
                        //shareButton()
                    }
                }
                .padding()
                
                reminderView()
            }
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(leading: cancelButton(), trailing: saveButton())
        }
    }
    
    private func pasteClipboard() {
        withAnimation {
            /// if editing try to paste clipboard content
            if storyToEdit == nil {
                if UIPasteboard.general.hasStrings,
                   let content = UIPasteboard.general.string {
                    model.text = content
                }
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
                .frame(width: 44, height: 32, alignment: .trailing)
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
                .foregroundColor(model.isFavorite ? Color(UIColor.systemOrange) : Color(UIColor.systemBlue))
                .imageScale(.large)
                .frame(width: 44, height: 32, alignment: .trailing)
        }
    }
    
    @ViewBuilder
    private func reminderView() -> some View {
        if eventStore.hasReminder(with: calendarItemIdentifier) {
            Image(systemName: "bell.fill")
                .foregroundColor(Color(UIColor.systemYellow))
                .font(.caption)
                .padding([.top, .trailing])
        }
    }
    
    private func cancelButton() -> some View {
        Button("Cancel") {
            presentation.wrappedValue.dismiss()
        }
    }
    
    private func saveButton() -> some View {
        Button("Save") {
            saveStory()
        }
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
            
            story.text = model.text
            story.tags = Array(model.tags)
            story.isFavorite = model.isFavorite
            story.calendarItemIdentifier = calendarItemIdentifier
            
            context.saveContext()
            
            presentation.wrappedValue.dismiss()
        }
    }
}

struct StoryEditorView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StoryEditorView()
                .previewLayout(.fixed(width: 350, height: 400))
            StoryEditorView(story: SampleData.story(storyIndex: 10, tagIndex: 3), remindersAccessGranted: true)
                .previewLayout(.fixed(width: 350, height: 400))
        }
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .environmentObject(EventStore())
        .preferredColorScheme(.dark)
    }
}
