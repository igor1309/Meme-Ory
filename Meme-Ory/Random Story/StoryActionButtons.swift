//
//  StoryActionButtons.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 04.12.2020.
//

import SwiftUI

struct StoryActionButtons: View {
    @Environment(\.managedObjectContext) private var context
    
    @ObservedObject var model: RandomStoryViewModel
    @ObservedObject var story: Story
    
    let labelStyle: MyButton.Style
    
    var body: some View {
//        Group {
            Section(header: Text("View")) {
                MyButton(title:"Show Random Story", icon: "wand.and.stars", labelStyle: labelStyle, action: { model.getRandomStory(hasHapticsAndAnimation: false) })
            }
            
            Section(header: Text("Create")) {
                MyButton(title:"Paste to new Story", icon: "doc.on.clipboard", labelStyle: labelStyle, action: model.pasteToNewStory)
                // to disable with .hasStrings its value should be updated
                //.disabled(!UIPasteboard.general.hasStrings)
                
                MyButton(title:"New Story", icon: "plus", labelStyle: labelStyle, action: model.createNewStory)
            }
            
            Section(header: Text("This Story")) {
                MyButton(title: "Remind me…", icon: "bell", labelStyle: labelStyle, action: model.remindMeAction)
                
                MyButton(title: story.isFavorite ? "Unfavorite" : "Favorite",
                         icon: story.isFavorite ? "star.slash" : "star",
                         labelStyle: labelStyle) {
                    story.isFavorite.toggle()
                }
                
                MyButton(title: "Copy Text", icon: "doc.on.doc", labelStyle: labelStyle, action: story.copyText)
                
                MyButton(title: "Share Story", icon: "square.and.arrow.up", labelStyle: labelStyle) {
                    shareText(story.text)
                }
                
                MyButton(title:"Edit Story", icon: "square.and.pencil", labelStyle: labelStyle, action: model.showStoryEditor)
                
                MyButton(title: "Edit Tags", icon: "tag", labelStyle: labelStyle, action: model.showTagGrid)
                
                MyButton(title: "Delete Story", icon: "trash", labelStyle: labelStyle, action: model.deleteStoryAction)
            }
            
            Section(header: Text("List")) {
                MyButton(title: "¿ Filter List by this tag (if one)", icon: "tag.circle", labelStyle: labelStyle) {
                    //  MARK: - FINISH THIS:
                }
                MyButton(title: "¿ List View Options", icon: "slider.horizontal.3", labelStyle: labelStyle) {
                    //  MARK: - FINISH THIS:
                }
            }
//        }
    }
    
    
    //  MARK: Share Story Text
    
    private func shareText(_ text: String) {
        let items = [text]
        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
    }
    
}

struct StoryActionButtons_Previews: PreviewProvider {
    static var previews: some View {
        List {
            StoryActionButtons(model: RandomStoryViewModel(context: SampleData.preview.container.viewContext), story: SampleData.story(), labelStyle: .none)
        }
    }
}
