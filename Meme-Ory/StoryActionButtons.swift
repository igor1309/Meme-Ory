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
    
    @Binding var showingDeleteConfirmation: Bool
    
    let labelStyle: MyButton.Style
    
    var body: some View {
        if let story = model.story {
            Group {
                Section(header: Text("View and List")) {
                    MyButton(title:"Show Random Story", icon: "wand.and.stars", labelStyle: labelStyle, action: { model.getRandomStory(noHapticsAndAnimation: true) })
                    MyButton(title: "¿ Filter List by this tag (if one)", icon: "tag.circle", labelStyle: labelStyle) {
                        //  MARK: - FINISH THIS:
                    }
                    MyButton(title: "¿ List View Options", icon: "slider.horizontal.3", labelStyle: labelStyle) {
                        //  MARK: - FINISH THIS:
                    }
                }
                
                Section(header: Text("Create")) {
                    MyButton(title:"Paste to new Story", icon: "doc.on.clipboard", labelStyle: labelStyle, action: model.pasteToNewStory)
                    // to disable with .hasStrings its value should be updated
                    //.disabled(!UIPasteboard.general.hasStrings)
                }
                
                Section(header: Text("This Story")) {
                    MyButton(title: "¿ Remind me…", icon: "bell", labelStyle: labelStyle) {
                        //  MARK: - FINISH THIS:
                    }
                    MyButton(title: story.isFavorite ? "Unfavorite" : "Favorite",
                             icon: story.isFavorite ? "star.slash" : "star",
                             labelStyle: labelStyle) {
                        story.isFavorite.toggle()
                    }
                    MyButton(title: "Copy Story text", icon: "doc.on.doc", labelStyle: labelStyle) {
                        UIPasteboard.general.string = story.text
                    }
                    MyButton(title: "Share Story", icon: "square.and.arrow.up", labelStyle: labelStyle, action: { shareText(story.text) })
                    
                    MyButton(title:"¿ Edit Story", icon: "square.and.pencil", labelStyle: labelStyle, action: model.showStoryEditor)
                    
                    MyButton(title: "¿ Edit Tags", icon: "tag", labelStyle: labelStyle, action: model.showTagGrid)
                    
                    MyButton(title: "Delete Story", icon: "trash", labelStyle: labelStyle) { showingDeleteConfirmation = true
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
    
    
    //  MARK: Share Story Text
    
    private func shareText(_ text: String) {
        let items = [text]
        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
    }
    
}

struct StoryActionButtons_Previews: PreviewProvider {
    @State static private var showingDeleteConfirmation = false
    
    static var previews: some View {
        List {
            StoryActionButtons(model: RandomStoryViewModel(context: SampleData.preview.container.viewContext), showingDeleteConfirmation: $showingDeleteConfirmation, labelStyle: .none)
        }
    }
}
