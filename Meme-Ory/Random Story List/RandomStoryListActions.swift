//
//  RandomStoryListActions.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 08.12.2020.
//

import SwiftUI

struct RandomStoryListActions: View {
    
    @ObservedObject var model: RandomStoryListViewModel
    
    var body: some View {
        Group {
            Section(header: Text("View")) {
                MyButton(title:"Show Random Story", icon: "wand.and.stars", action: { model.getRandomStory(hasHapticsAndAnimation: false) })
            }
            
            Section(header: Text("Create")) {
                MyButton(title:"Paste to New Story", icon: "doc.on.clipboard", action: model.pasteToNewStory)
                    // to disable with .hasStrings its value should be updated
                    //.disabled(!UIPasteboard.general.hasStrings)
                
                MyButton(title:"New Story", icon: "plus", action: model.createNewStory)
            }
            
            Section(header: Text("Import & Export")) {
                MyButton(title: "Import Stories", icon: "arrow.down.doc.fill", labelStyle: .none, withHaptics: true, useAnimation: true, action: model.importFile)
                MyButton(title: "Export Stories", icon: "arrow.up.doc.fill", action: model.exportFile)
                MyButton(title: "Share Stories", icon: "square.and.arrow.up", action: model.shareStories)
            }
            
        }
    }
}

struct StoryListActions_Previews: PreviewProvider {
    @State static var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        List {
            RandomStoryListActions(model: RandomStoryListViewModel(context: context))
        }
        .previewLayout(.fixed(width: 350, height: 500))
        .environment(\.sizeCategory, .extraLarge)
        .environment(\.managedObjectContext, context)
        .environmentObject(Filter())
        .environmentObject(EventStore())
    }
}
