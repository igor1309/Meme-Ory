//
//  StoryEditorView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI
import EventKit

final class StoryEditorViewModel: ObservableObject {
    @Published var text: String
    @Published var tags: Set<Tag>
    @Published var isFavorite: Bool
    
    init() {
        text = ""
        tags = []
        isFavorite = false
    }
    
    init(text: String, tags: Set<Tag>, isFavorite: Bool) {
        self.text = text
        self.tags = tags
        self.isFavorite = isFavorite
    }
}

struct StoryEditorView: View {
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) private var presentation
    
    @StateObject private var model: StoryEditorViewModel
    
    private let storyToEdit: Story?
    private let title: String
    
    var reminder: EKReminder?
    
    /// Create new Story
    init() {
        _model = StateObject(wrappedValue: StoryEditorViewModel())
        storyToEdit = nil
        title = "New"
    }
    
    /// Edit Existing Story
    init(story: Story, remindersAccessGranted: Bool) {
        let model = StoryEditorViewModel(text: story.text, tags: Set(story.tags), isFavorite: story.isFavorite)
        _model = StateObject(wrappedValue: model)
        storyToEdit = story
        title = ""
        
        //  MARK: - FINISH THIS
        // can't access this in init!
        if remindersAccessGranted {
            reminder = EKEventStore().calendarItem(withIdentifier: story.calendarItemIdentifier) as? EKReminder
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading) {
                    TextEditor(text: $model.text)
                        .onAppear(perform: pasteClipboard)
                    
                    HStack(alignment: .top) {
                        StoryTagView(tags: $model.tags)
                        
                        Spacer()
                        
                        toggleFavoriteButton()
                    }
                    .padding(.top, 6)
                    
                }
                .padding()
                
                if reminder != nil {
                    Image(systemName: "bell.fill")
                        .foregroundColor(Color(UIColor.systemYellow))
                        .imageScale(.small)
                        .font(.caption)
                        .padding([.top, .trailing])
                }
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
    
    private func toggleFavoriteButton() -> some View {
        Button {
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                model.isFavorite.toggle()
            }
        } label: {
            Image(systemName: model.isFavorite ? "star.circle" : "star")
                .foregroundColor(model.isFavorite ? Color(UIColor.systemYellow) : Color(UIColor.systemBlue))
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
