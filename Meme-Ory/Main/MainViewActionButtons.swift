//
//  MainViewActionButtons.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

struct MainViewActionButtons: View {
    
    @EnvironmentObject private var model: MainViewModel
    
    let stories: [Story]
    
    var body: some View {
        Section(header: Text("View Mode")) {
            Picker("Select", selection: $model.viewMode) {
                ForEach(MainViewModel.ViewMode.allCases, id: \.self) { mode in
                    mode.label()
                        .tag(mode)
                }
            }
        }
        
        LabeledButton(title: "Maintenance", icon: "wrench.and.screwdriver", action: model.showMaintenance)
        
        Section(header: Text("Import & Export")) {
            LabeledButton(title: "Import Stories", icon: "arrow.down.doc.fill", labelStyle: .none, action: model.importFile)
            LabeledButton(title: "Backup Stories", icon: "tray.and.arrow.down") {
                model.exportFile(stories: stories)
            }
            LabeledButton(title: "Share Stories", icon: "square.and.arrow.up") {
                model.shareStories(stories: stories)
            }
        }
    }
}


struct MainViewActions_Previews: PreviewProvider {
    @State static private var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        List {
            MainViewActionButtons(stories: (0..<6).map {
                SampleData.story(storyIndex: $0)
            })
        }
        .listStyle(InsetGroupedListStyle())
        .environmentObject(MainViewModel(context: context))
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 350, height: 500))
    }
}
