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
                Text(story.tagList)
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
                Text("Copy to clipboard")
                Image(systemName: "doc.on.doc")
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
    formatter.timeStyle = .medium
    return formatter
}()

struct StoryRowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List(0..<5) { _ in
                StoryListRowView(story: SampleData.story)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 350, height: 800))
    }
}