//
//  RandomStoryListActions.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 08.12.2020.
//

import SwiftUI

struct RandomStoryListActions: View {
    
    @EnvironmentObject var model: RandomStoryListViewModel
    
    var body: some View {
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
        
        Section {
            MyButton(title: "Maintenance", icon: "wrench.and.screwdriver.fill") {
                model.sheetID = .maintenance
            }
        }
        
        MyButton(title: "Single Story UI", icon: "doc.plaintext") {
            model.sheetID = .singleStoryUI
        }
    }
}

struct StoryListActions_Previews: PreviewProvider {
    @State static var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        List {
            RandomStoryListActions()
                .environmentObject(RandomStoryListViewModel(context: context))
        }
        .listStyle(InsetGroupedListStyle())
        .previewLayout(.fixed(width: 350, height: 500))
        .environment(\.sizeCategory, .extraLarge)
        .environment(\.managedObjectContext, context)
        .environmentObject(Filter())
        .environmentObject(EventStore())
    }
}
