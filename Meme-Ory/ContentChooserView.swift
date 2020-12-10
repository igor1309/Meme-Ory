//
//  ContentChooserView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 09.12.2020.
//

import SwiftUI
import CoreData

enum ContentChooser: String, CaseIterable, Identifiable {
    case randomList, randomStory, orderedList, notSelected, maintenance
    
    var id: Int { hashValue }
    
    var rawValue: String {
        switch self {
            case .notSelected: return "Select..."
            case .orderedList: return "Ordered List"
            case .randomList:  return "Random List"
            case .randomStory: return "Random Story"
            case .maintenance: return "Maintenance"
        }
    }
}

struct ContentChooserView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject var filter: Filter
    
    //@AppStorage("chooser") private var chooser: ContentChooser = .notSelected
    @State private var chooser: ContentChooser = .notSelected
    
    var body: some View {
        switch chooser {
            case .notSelected:
                Picker("Choose UI", selection: $chooser) {
                    ForEach(ContentChooser.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
            case .orderedList:
                // Text(chooser.rawValue)
                // Button("Reset") {
                //     chooser = .notSelected
                // }
                NavigationView {
                    StoryListView(filter: filter, showPasteButton: true)
                }
                
            case .randomList:
                //Text(chooser.rawValue)
                //Button("Reset") {
                //    chooser = .notSelected
                //}
                RandomStoryListView(context: context)
                
            case .randomStory:
                //Text(chooser.rawValue)
                //Button("Reset") {
                //    chooser = .notSelected
                //}
                RandomStoryViewWrapper(context: context)
                
            case .maintenance:
                MaintenanceView(context: context)
        }
    }
}

struct ContentChooserView_Previews: PreviewProvider {
    static var previews: some View {
        ContentChooserView()
            .preferredColorScheme(.dark)
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .environmentObject(EventStore())
            .environmentObject(Filter())
    }
}
