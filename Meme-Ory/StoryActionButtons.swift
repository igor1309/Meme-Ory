//
//  StoryActionButtons.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 04.12.2020.
//

import SwiftUI

struct StoryActionButtons: View {
    @Environment(\.managedObjectContext) private var context
    
    @ObservedObject var story: Story
    
    @Binding var storyURL: URL?
    @Binding var showingDeleteConfirmation: Bool
    
    let labelStyle: MyButton.Style
    
    var body: some View {
        Group {
            Section(header: Text("View and List")) {
                MyButton(title:"Show Random Story", icon: "wand.and.stars", labelStyle: labelStyle, action: getRandomStory)
                MyButton(title: "Filter List by this tag (if one)", icon: "tag.circle", labelStyle: labelStyle) {
                    //  MARK: - FINISH THIS:
                }
                MyButton(title: "List View Options", icon: "slider.horizontal.3", labelStyle: labelStyle) {
                    //  MARK: - FINISH THIS:
                }
            }
            
            Section(header: Text("Create")) {
                MyButton(title:"Paste to new Story", icon: "doc.on.clipboard", labelStyle: labelStyle, action: pasteToNewStory)
                // to disable with .hasStrings its value should be updated
                //.disabled(!UIPasteboard.general.hasStrings)
            }
            
            Section(header: Text("This Story")) {
                MyButton(title: "Remind me…", icon: "bell", labelStyle: labelStyle) {
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
                MyButton(title: "Share Story", icon: "square.and.arrow.up", labelStyle: labelStyle, action: shareText)
                MyButton(title:"Edit Story", icon: "square.and.pencil", labelStyle: labelStyle) {
                    //  MARK: - FINISH THIS:
                }
                MyButton(title: "Edit Tags", icon: "tag", labelStyle: labelStyle) {
                    //  MARK: - FINISH THIS:
                }
                
                MyButton(title: "Delete Story", icon: "trash", labelStyle: labelStyle) { showingDeleteConfirmation = true
                }
            }
        }
    }
    
    
    // MARK: Get Random Story
    
    private func getRandomStory() {
        storyURL = Story.oneRandom(in: context)?.url
    }
    
    
    // MARK: Create New Story and paste clipboard content
    
    private func pasteToNewStory() {
        if UIPasteboard.general.hasStrings,
           let content = UIPasteboard.general.string,
           !content.isEmpty {
            let story = Story(context: context)
            story.text = content
            story.timestamp = Date()
            
            context.saveContext()
            
            storyURL = Story.last(in: context)?.url
        }
    }
    
    
    //  MARK: Share Story Text
    
    private func shareText() {
        let items = [story.text]
        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
    }
        
}

struct StoryActionButtons_Previews: PreviewProvider {
    @State static private var showingDeleteConfirmation = false
    
    static var previews: some View {
        List {
            StoryActionButtons(story: SampleData.story(), storyURL: .constant(nil), showingDeleteConfirmation: $showingDeleteConfirmation, labelStyle: .none)
        }
    }
}
