//
//  StoryActionButtons.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

struct StoryActionButtons: View {
    
    @ObservedObject private var model: MainViewModel
    @ObservedObject private var story: Story
    
    init(model: MainViewModel, story: Story) {
        self.model = model
        self.story = story
    }
    
    var labelStyle: LabeledButton.Style = .none
    
    var body: some View {
        Section(header: Text("Create")) {
            LabeledButton(title:"Paste to new Story", icon: "doc.on.clipboard", labelStyle: labelStyle, action: model.pasteToNewStory)
            // to disable with .hasStrings its value should be updated
            //.disabled(!UIPasteboard.general.hasStrings)
            
            LabeledButton(title:"New Story", icon: "plus", labelStyle: labelStyle, action: model.createNewStory)
        }
        
        Section(header: Text("This Story")) {
            LabeledButton(title: "Remind me…", icon: "bell", labelStyle: labelStyle) {
                model.remindMeAction(story: story)
            }
            
            LabeledButton(title: story.isFavorite ? "Unfavorite" : "Favorite",
                     icon: story.isFavorite ? "star.slash" : "star",
                     labelStyle: labelStyle) {
                story.isFavorite.toggle()
            }
            
            LabeledButton(title: "Copy Text", icon: "doc.on.doc", labelStyle: labelStyle, action: story.copyText)
            
            LabeledButton(title: "Share Story", icon: "square.and.arrow.up", labelStyle: labelStyle) {
                model.shareText(story.text)
            }
        }
        
        Section(header: Text("Edit")) {
            LabeledButton(title:"Edit Story", icon: "square.and.pencil", labelStyle: labelStyle) {
                model.showStoryEditor(story: story)
            }
            
            LabeledButton(title: "Edit Tags", icon: "tag", labelStyle: labelStyle) {
                model.showTagGrid(story: story)
            }
            
            LabeledButton(title: "Delete Story", icon: "trash", labelStyle: labelStyle, action: model.deleteStoryAction)
        }
    }
}

struct StoryActionButtons_Previews: PreviewProvider {
    
    @State static private var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        List {
            StoryActionButtons(
                model: .init(context: context),
                story: SampleData.story()
            )
        }
        .listStyle(InsetGroupedListStyle())
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 350, height: 700))
    }
}
