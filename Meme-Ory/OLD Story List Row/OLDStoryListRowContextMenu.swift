//
//  OLDStoryListRowContextMenu.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 08.12.2020.
//

import SwiftUI

struct OLDStoryListRowContextMenu: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var filter: Filter
    
    @ObservedObject var story: Story
    @ObservedObject var model: OLDStoryListRowViewModel
    
    var body: some View {
        Group {
            Section {
                /// toggle favotite
                MyButton(title: story.isFavorite ? "Unfavorite" : "Favorite", icon: story.isFavorite ? "star" : "star.fill", action: toggleFavorite)
                
                /// setting reminders using with Action Sheet
                MyButton(title: "Remind me...", icon: "bell", action: model.remindMe)
            }
            
            /// edit story
            MyButton(title: "Edit Story", icon: "square.and.pencil", action: model.editStory)
            
            /// copy story text
            MyButton(title: "Copy Story Text", icon: "doc.on.doc", action: story.copyText)
            
            /// share sheet
            ShareStoryButtons(text: story.text, url: story.url)
        }
    }
    
    func toggleFavorite() {
        story.isFavorite.toggle()
        context.saveContext()
    }
    
    private func filterByTagSection() -> some View {
        Section {
            // only for stories with just one tag
            if story.tags.count == 1 {
                if filter.tags == Set(story.tags) {
                    // filter by this tag was already set
                    MyButton(title: "Reset tags", icon: "tag.slash") {
                        filter.tags = []
                    }
                } else {
                    // set filter by this tag
                    MyButton(title: "Filter by this tag", icon: "tag") {
                        filter.tags = Set(story.tags)
                    }
                }
            }
        }
    }
    
}

struct OLDStoryListRowContextMenu_Previews: PreviewProvider {
    @StateObject static var model = OLDStoryListRowViewModel()
    
    static var previews: some View {
        Group {
            List {
                OLDStoryListRowContextMenu(story: SampleData.story(), model: model)
            }
            .previewLayout(.fixed(width: 350, height: 400))
        }
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .environmentObject(Filter())
        .environmentObject(EventStore())
    }
}
