//
//  StoryActionButtons.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

struct StoryActionButtons: View {
    
    @EnvironmentObject private var model: MainViewModel
    
    @ObservedObject var story: Story
    
    var labelStyle: MyButton.Style = .none
    
    var body: some View {
        Section(header: Text("Create")) {
            MyButton(title:"Paste to new Story", icon: "doc.on.clipboard", labelStyle: labelStyle, action: model.pasteToNewStory)
            // to disable with .hasStrings its value should be updated
            //.disabled(!UIPasteboard.general.hasStrings)
            
            MyButton(title:"New Story", icon: "plus", labelStyle: labelStyle, action: model.createNewStory)
        }
        
        Section(header: Text("This Story")) {
            MyButton(title: "Remind me…", icon: "bell", labelStyle: labelStyle) {
                model.remindMeAction(story: story)
            }
            
            MyButton(title: story.isFavorite ? "Unfavorite" : "Favorite",
                     icon: story.isFavorite ? "star.slash" : "star",
                     labelStyle: labelStyle) {
                story.isFavorite.toggle()
            }
            
            MyButton(title: "Copy Text", icon: "doc.on.doc", labelStyle: labelStyle, action: story.copyText)
            
            MyButton(title: "Share Story", icon: "square.and.arrow.up", labelStyle: labelStyle) {
                model.shareText(story.text)
            }
        }
        
        Section(header: Text("Edit")) {
            MyButton(title:"Edit Story", icon: "square.and.pencil", labelStyle: labelStyle) {
                model.showStoryEditor(story: story)
            }
            
            MyButton(title: "Edit Tags", icon: "tag", labelStyle: labelStyle) {
                model.showTagGrid(story: story)
            }
            
            MyButton(title: "Delete Story", icon: "trash", labelStyle: labelStyle, action: model.deleteStoryAction)
        }
    }
}

struct StoryActionButtons_Previews: PreviewProvider {
    @State static private var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        List {
            StoryActionButtons(story: SampleData.story())
        }
        .listStyle(InsetGroupedListStyle())
        .environmentObject(MainViewModel(context: context))
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 350, height: 700))
    }
}
