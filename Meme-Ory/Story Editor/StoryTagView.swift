//
//  StoryTagView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 24.11.2020.
//

import SwiftUI

struct StoryTadViewWrapper: View {
    
    @ObservedObject var story: Story
    
    let hasButton: Bool
    
    var body: some View {
        let tags = Binding(
            get: { Set(story.tags) },
            set: { story.tags = Array($0).sorted() }
        )
        
        return StoryTagView(tags: tags, hasButton: hasButton)
    }
}

struct StoryTagView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @Binding var tags: Set<Tag>
    
    var hasButton: Bool = true
    
    private var tagNames: String {
        tags.map { $0.name }.joined(separator: ", ")
    }
    
    @State private var showingTagGrid = false
    
    var body: some View {
        HStack(alignment: .top) {
            if !tagNames.isEmpty {
                Text(tagNames)
                    .foregroundColor(Color(UIColor.systemOrange))
                    .font(.caption)
                    .padding(.top, 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .contextMenu {
                        MyButton(title: "Edit Tags", icon: "tag", action: showTagGrid)
                    }
            }
            
            if hasButton {
                Spacer()
                
                tagsButton()
            }
        }
    }
    
    private func tagsButton() -> some View {
        Button(action: showTagGrid) {
            Image(systemName: "tag")
                .imageScale(.large)
                .frame(width: 44, height: 32)
        }
        .sheet(isPresented: $showingTagGrid) {
            TagGridWrapperView(selected: $tags)
                .environment(\.managedObjectContext, context)
        }
    }
    
    private func showTagGrid() {
        Ory.withHapticsAndAnimation {
            showingTagGrid = true
        }
    }
}

fileprivate struct StoryTagView_Testing: View {
    @State private var tags = SampleData.tags
    
    var body: some View {
        StoryTagView(tags: $tags)
    }
}

struct StoryTagView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
                Spacer()
                
                StoryTagView_Testing()
                    .border(Color.pink.opacity(0.6))
                    .padding()
            }
        }
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .environment(\.colorScheme, .dark)
        .previewLayout(.fixed(width: 350, height: 400))
    }
}
