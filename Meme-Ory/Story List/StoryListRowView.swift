//
//  StoryListRowView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

extension View {
    func applyViewOptions(_ viewOptions: MainViewModel.ViewOptions) -> some View {
        self
            .font(viewOptions.font)
    }
}

struct StoryListRowView: View {
    
    @EnvironmentObject private var model: MainViewModel
    
    @ObservedObject var story: Story
    
    var body: some View {
        Text(story.text)
            .applyViewOptions(model.viewOptions)
    }
}


struct StoryListRowView_Previews: PreviewProvider {
    @State static var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        NavigationView {
            List {
                StoryListRowView(story: SampleData.story())
                
                Section {
                    StoryListRowView(story: SampleData.story())
                    StoryListRowView(story: SampleData.story(storyIndex: 1))
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Story List Row View")
            .navigationBarTitleDisplayMode(.inline)
        }
        .environmentObject(MainViewModel(context: context))
        .environmentObject(EventStore())
        .environment(\.sizeCategory, .large)
        .environment(\.colorScheme, .dark)
        .previewLayout(.fixed(width: 350, height: 500))
    }
}
