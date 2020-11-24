//
//  StoryTagView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 24.11.2020.
//

import SwiftUI

struct StoryTagView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @Binding var tags: Set<Tag>
    
    private var tagList: String {
        tags.map { $0.name }.joined(separator: ", ")
    }
    
    @State private var showTagsView = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Tags".uppercased())
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Button {
                    let haptics = Haptics()
                    haptics.feedback()
                    
                    withAnimation {
                        showTagsView = true
                    }
                } label: {
                    Image(systemName: "tag.circle")
                        .imageScale(.large)
                }
                .sheet(isPresented: $showTagsView) {
                    TagGridWrapperView(selected: $tags)
                        .environment(\.managedObjectContext, context)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if !tagList.isEmpty {Text(tagList)
                .foregroundColor(Color(UIColor.systemOrange))
                .font(.caption)
                .contextMenu {
                    Button {
                        let haptics = Haptics()
                        haptics.feedback()
                        
                        withAnimation {
                            showTagsView = true
                        }
                    } label: {
                        Label("Edit Tags", systemImage: "tag.circle")
                    }
                }
            }
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
                    .padding()
            }
        }
        .environment(\.colorScheme, .dark)
        .previewLayout(.fixed(width: 350, height: 400))
    }
}
