//
//  StoryImportTester.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 12.12.2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct StoryImportTester: View {
    @State private var showingFileImporter = false
    
    var body: some View {
        NavigationView {
            StoryImportTesterListView()
                .storyImporter(isPresented: $showingFileImporter)
                .toolbar(content: toolbar)
        }
    }
    
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            LabeledButton(title: "Import File", icon: "arrow.down.doc") {
                showingFileImporter = true
            }
        }
    }
}

struct StoryImportTesterListView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest private var stories: FetchedResults<Story>
    
    init() {
        let predicate = NSPredicate.all
        let request = Story.fetchRequest(predicate)
        _stories = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        List {
            Section(header: Text("stories: \(stories.count)")) {
                ForEach(stories) { story in
                    Text(story.text)
                        .lineLimit(2)
                        .font(.subheadline)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("File Import Tester")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FileImportTester_Previews: PreviewProvider {
    static var previews: some View {
        StoryImportTester()
    }
}
