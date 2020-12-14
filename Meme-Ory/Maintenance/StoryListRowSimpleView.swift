//
//  StoryListRowSimpleView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

struct StoryListRowSimpleView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var model: MaintenanceViewModel
    
    @ObservedObject var story: Story
    
    @State private var sheetID: SheetID?
    
    enum SheetID: Identifiable {
        case split, showStory
        var id: Int { hashValue }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(story.text)
                .lineLimit(model.hasTimestampDate ? nil : 2)
                .if(hasDeleteMark.wrappedValue) { $0.foregroundColor(Color(UIColor.systemRed)) }
                .font(.subheadline)
            
            if !story.tagList.isEmpty {
                Label(story.tagList, systemImage: "tag")
                    .foregroundColor(Color(UIColor.systemOrange))
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .padding(.vertical, 3)
        .onTapGesture(count: 1, perform: toggleMarkDelete)
        .contextMenu(menuItems: menuContent)
        .sheet(item: $sheetID, content: splitView)
    }
    
    @ViewBuilder
    private func menuContent() -> some View {
        LabeledButton(title: "Show Story", icon: "doc.text.magnifyingglass", action: showStory)
        LabeledButton(title: "Split Story", icon: "scissors", action: splitStory)
        LabeledButton(title: hasDeleteMark.wrappedValue ? "Unmark delete" : "Mark to delete", icon: hasDeleteMark.wrappedValue ? "trash.slash" : "trash", action: toggleMarkDelete)
    }
    
    private func showStory() {
        sheetID = .showStory
    }
    
    private func splitStory() {
        sheetID = .split
    }
    
    private func toggleMarkDelete() {
        hasDeleteMark.wrappedValue.toggle()
    }
    
    private var hasDeleteMark: Binding<Bool> {
        Binding(
            get: { story.tags.contains(model.markDeleteTag) },
            set: {
                if $0 {
                    story.tags.insert(model.markDeleteTag, at: 0)
                } else {
                    story.tags.removeAll { $0 == model.markDeleteTag }
                }
            }
        )
    }
    
    @ViewBuilder
    private func splitView(sheetID: SheetID) -> some View {
        switch sheetID {
            case .split:
                let split = story.text.splitText()
                if split.count == 1 {
                    StorySimpleView(text: story.text, title: "Can't split this story")
                } else {
                    ImportTextView(texts: split, title: "Story Split")
                        .environment(\.managedObjectContext, context)
                }
                
            case .showStory:
                StorySimpleView(story: story)
        }
    }
}

struct StoryListRowSimpleView_Previews: PreviewProvider {
    @State static private var context = SampleData.preview.container.viewContext

    static var previews: some View {
        List {
            ForEach(0..<6) {
                StoryListRowSimpleView(story: SampleData.story(storyIndex: $0))
            }
        }
        .listStyle(InsetGroupedListStyle())
        .environment(\.managedObjectContext, context)
        .environmentObject(MaintenanceViewModel(context: context))
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 350, height: 600))
    }
}
