//
//  StoryEditorView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

struct StoryEditorView: View {
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) private var presentation
    
    @State private var text: String
    @State private var tags: Set<Tag>
    
    private let storyToEdit: Story?
    private let title: String
    
    /// Create new Story
    init() {
        _text = State(initialValue: "")
        _tags = State(initialValue: [])
        storyToEdit = nil
        title = "New"
    }
    
    /// Edit Existing Story
    init(story: Story) {
        _text = State(initialValue: story.text)
        _tags = State(initialValue: Set(story.tags))
        storyToEdit = story
        title = ""
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextEditor(text: $text)
                    .onAppear(perform: pasteClipboard)
                
                StoryTagView(tags: $tags)
            }
            .padding()
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentation.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveStory()
                }
                .disabled(text.isEmpty)
            )
        }
    }
    
    private func pasteClipboard() {
        withAnimation {
            /// if editing try to paste clipboard content
            if storyToEdit == nil {
                if UIPasteboard.general.hasStrings,
                   let content = UIPasteboard.general.string {
                    text = content
                }
            }
        }
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
            
            story.text = text
            story.tags = Array(tags)
            
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
            StoryEditorView(story: SampleData.story(storyIndex: 9, tagIndex: 3))
                .previewLayout(.fixed(width: 350, height: 400))
        }
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .preferredColorScheme(.dark)
    }
}
