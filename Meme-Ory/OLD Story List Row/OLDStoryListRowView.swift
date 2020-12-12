//
//  OLDStoryListRowView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

struct OLDStoryListRowView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var filter: Filter
    @EnvironmentObject private var eventStore: EventStore
    
    @StateObject var model: OLDStoryListRowViewModel
    
    @ObservedObject var story: Story
    
    init(story: Story, lineLimit: Int? = nil) {
        self.story = story
        self.lineLimit = lineLimit
        _model = StateObject(wrappedValue: OLDStoryListRowViewModel())
    }
    
    var lineLimit: Int? = 3
    
    var body: some View {
        label
            .contextMenu {
                OLDStoryListRowContextMenu(story: story, model: model)
            }
            .contentShape(Rectangle())
            .onAppear(perform: handleOnApper)
            .sheet(item: $model.sheetID, content: storySheet)
            .actionSheet(item: $model.actionSheetID, content: actionSheet)
    }
    
    private func handleOnApper() {
        eventStore.reminderCleanup(for: story, in: context)
    }
    
    @ViewBuilder
    private func storySheet(sheetID: OLDStoryListRowViewModel.SheetID) -> some View {
        switch sheetID {
            case .edit:
                NavigationView {
                    StoryEditorView(story: story)
                }
                .environment(\.managedObjectContext, context)
                .environmentObject(eventStore)
        }
    }
    
    private func actionSheet(actionSheetID: OLDStoryListRowViewModel.ActionSheetID) -> ActionSheet {
        switch actionSheetID {
            case .remindMe:
                return eventStore.remindMeActionSheet(for: story, in: context)
        }
    }
    
    var label: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 3) {
                Text(story.text)//.storyText())
                    .lineLimit(lineLimit)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
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
                    Text("\(timestamp, formatter: Ory.storyFormatter)")
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                        .font(.caption)
                }
            }
            
            HStack {
                if story.hasReminder {
                    Image(systemName: "bell")
                        .foregroundColor(Color(UIColor.systemTeal))
                    
                }
                
                if story.isFavorite {
                    Image(systemName: "star.circle")
                        .foregroundColor(Color(UIColor.systemOrange))
                }
            }
            .font(.caption)
        }
        .padding(.vertical, 3)
    }
}

fileprivate struct OLDStoryListRowView_Testing: View {
    @State private var activeURL: URL?
    
    var body: some View {
        NavigationView {
            List(0..<SampleData.texts.count) { index in
                OLDStoryListRowView(story: SampleData.story(storyIndex: index))
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct OLDStoryRowView_Previews: PreviewProvider {
    @StateObject static var model = OLDStoryListRowViewModel()
    
    static var previews: some View {
        Group {
            List {
                OLDStoryListRowContextMenu(story: SampleData.story(), model: model)
            }
            .previewLayout(.fixed(width: 350, height: 400))
            
            OLDStoryListRowView_Testing()
                .previewLayout(.fixed(width: 350, height: 600))
                .preferredColorScheme(.dark)
        }
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .environmentObject(Filter())
        .environmentObject(EventStore())
    }
}
