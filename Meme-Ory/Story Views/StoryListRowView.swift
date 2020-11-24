//
//  StoryListRowView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI
import MobileCoreServices

struct StoryListRowView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @ObservedObject var story: Story
    
    @Binding var filter: Filter
    
    @State private var showSheet = false
    
    var body: some View {
        Button {
            showSheet = true
        } label: {
            label
        }
        // .buttonStyle(PlainButtonStyle())
        .accentColor(.primary)
        .contentShape(Rectangle())
        .sheet(isPresented: $showSheet) {
            StoryEditorView(story: story)
                .environment(\.managedObjectContext, context)
        }
    }
    
    var label: some View {
        VStack(alignment: .leading) {
            Text(storyText())
                .font(.subheadline)
            
            if !story.tagList.isEmpty {
                Label {
                    Text(story.tagList)
                } icon: {
                    Image(systemName: "tag")
                        .imageScale(.small)
                }
                .foregroundColor(.orange)
                .font(.caption)
            }
            
            if let timestamp = story.timestamp {
                Text("\(timestamp, formatter: storyFormatter)")
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .font(.caption)
            }
        }
        .padding(.vertical, 3)
        .contextMenu {
            Button {
                let haptics = Haptics()
                haptics.feedback()
                
                withAnimation {
                    UIPasteboard.general.string = story.text
                }
            } label: {
                Text("Copy story")
                Image(systemName: "doc.on.doc")
            }
            /// if just one tag - filter by this tag
            if story.tags.count == 1 {
                Button {
                    filter.tags = Set(story.tags)
                } label: {
                    Label("Filter by this tag", systemImage: "tag")
                }
            }
        }
    }
    
    private func storyText() -> String {
        let maxCount = 100
        let maxLines = 3
        
        var text = story.text
        if text.count > maxCount {
            text = text.prefix(maxCount).appending(" ...")
        }
        
        let lines = text.components(separatedBy: "\n")
        if lines.count > maxLines {
            text = lines.prefix(maxLines).joined(separator: "\n").appending(" ...")
        }
        
        return text
    }
}

private let storyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

fileprivate struct StoryListRowView_Testing: View {
    @State var filter = Filter()
    
    var body: some View {
        NavigationView {
            List(0..<SampleData.stories.count) { index in
                StoryListRowView(story: SampleData.story(storyIndex: index), filter: $filter)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StoryRowView_Previews: PreviewProvider {
    static var previews: some View {
        StoryListRowView_Testing()
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 350, height: 800))
    }
}
