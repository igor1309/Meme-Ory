//
//  StoryEditorView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

final class StoryEditorViewModel: ObservableObject {
    @Published var text: String
    @Published var tags: Set<Tag>
    
    init() {
        text = ""
        tags = []
    }
    
    init(text: String, tags: Set<Tag>) {
        self.text = text
        self.tags = tags
    }
}

struct StoryEditorView: View {
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) private var presentation
    
    @StateObject private var model: StoryEditorViewModel
    
    private let storyToEdit: Story?
    private let title: String
    
    /// Create new Story
    init() {
        _model = StateObject(wrappedValue: StoryEditorViewModel())
        storyToEdit = nil
        title = "New"
    }
    
    /// Edit Existing Story
    init(story: Story) {
        let model = StoryEditorViewModel(text: story.text, tags: Set(story.tags))
        _model = StateObject(wrappedValue: model)
        storyToEdit = story
        title = ""
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextEditor(text: $model.text)
                    .onAppear(perform: pasteClipboard)
                
                StoryTagView(tags: $model.tags)
                    .padding(.top, 6)
            }
            .padding()
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
            StoryEditorView(story: SampleData.story(storyIndex: 10, tagIndex: 3))
                .previewLayout(.fixed(width: 350, height: 400))
        }
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .preferredColorScheme(.dark)
    }
}
