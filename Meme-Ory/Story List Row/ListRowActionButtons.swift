//
//  ListRowActionButtons.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

struct ListRowActionButtons: View {
    
    @Environment(\.managedObjectContext) private var context

    @EnvironmentObject private var model: MainViewModel

    @ObservedObject var story: Story
    
    var body: some View {
        Section {
            /// toggle favotite
            MyButton(title: story.isFavorite ? "Unfavorite" : "Favorite", icon: story.isFavorite ? "star" : "star.fill", action: toggleFavorite)
            
            /// setting reminders using with Action Sheet
            MyButton(title: "Remind me...", icon: "bell") {
                model.remindMeAction(story: story)
            }
        }
        
        /// edit story
        MyButton(title: "Edit Story", icon: "square.and.pencil") {
            model.showStoryEditor(story: story)
        }
        
        /// copy story text
        MyButton(title: "Copy Story Text", icon: "doc.on.doc", action: story.copyText)
        
        /// share sheet
        ShareStoryButtons(text: story.text, url: story.url)
    }
    
    func toggleFavorite() {
        story.isFavorite.toggle()
        context.saveContext()
    }
}

struct ListRowActionButtons_Previews: PreviewProvider {
    static var previews: some View {
        ListRowActionButtons(story: SampleData.story())
    }
}
