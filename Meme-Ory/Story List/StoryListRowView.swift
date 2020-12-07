//
//  StoryListRowView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI
import EventKit
import MobileCoreServices

struct StoryListRowView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var filter: Filter
    @EnvironmentObject private var eventStore: EventStore
    
    @ObservedObject var story: Story
    
    @State private var showingStorySheet = false
    
    var body: some View {
        label
            .contextMenu {
                /// toggle favotite
                toggleFavoriteButton()
                /// copy story text
                copyStoryTextButton()
                /// share sheet
                ShareStoryButtons(text: story.text, url: story.url)
                /// setting reminders
                remindMeButton()
                //remindMeSection()
                /// if story has just one tag - filter by this tag
                filterByTagSection()
            }
            .contentShape(Rectangle())
            .onAppear {
                story.reminderCleanUp(eventStore: eventStore, context: context)
            }
            .sheet(isPresented: $showingStorySheet, content: storySheet)
            .actionSheet(isPresented: $showRemindMeActionSheet, content: remindMeActionSheet)
    }
    
    private func storySheet() -> some View {
        NavigationView {
            StoryEditorView(story: story)
        }
        .environment(\.managedObjectContext, context)
        .environmentObject(eventStore)
    }
    
    var label: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 3) {
                Text(story.text)//.storyText())
                    .lineLimit(3)
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
                    Text("\(timestamp, formatter: storyFormatter)")
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
    
    private func toggleFavoriteButton() -> some View {
        Button {
            Ory.withHapticsAndAnimation {
                story.isFavorite.toggle()
                context.saveContext()
            }
        } label: {
            Label(story.isFavorite ? "Unfavorite" : "Favorite",
                  systemImage: story.isFavorite ? "star" : "star.fill"
            )
        }
    }
    
    private func copyStoryTextButton() -> some View {
        Button {
            Ory.withHapticsAndAnimation {
                story.copyText()
            }
        } label: {
            Text("Copy story text")
            Image(systemName: "doc.on.doc")
        }
    }
    
    private func filterByTagSection() -> some View {
        Section {
            // only for stories with just one tag
            if story.tags.count == 1 {
                if filter.tags == Set(story.tags) {
                    // filter by this tag was already set
                    Button {
                        Ory.withHapticsAndAnimation {
                            filter.tags = []
                        }
                    } label: {
                        Label("Reset tags", systemImage: "tag.slash")
                    }
                } else {
                    // set filter by this tag
                    Button {
                        Ory.withHapticsAndAnimation {
                            filter.tags = Set(story.tags)
                        }
                    } label: {
                        Label("Filter by this tag", systemImage: "tag")
                    }
                }
            }
        }
    }
    
    @State private var showRemindMeActionSheet = false
    /// using with Action Sheet
    private func remindMeButton() -> some View {
        Button {
            Ory.withHapticsAndAnimation {
                showRemindMeActionSheet = true
            }
        } label: {
            Label("Remind me...", systemImage: "bell")
        }
    }
    
    private func remindMeActionSheet() -> ActionSheet {
        let remindingButtons = EventStore.components.map { component in
            ActionSheet.Button.default(Text("\(component.str)")) {
                story.remindMeNext(component, eventStore: eventStore, context: context)
            }
        }
        
        return ActionSheet (
            title: Text("Remind Me...".uppercased()),
            message: Text("Select when you want to be reminded."),
            buttons: remindingButtons + [ActionSheet.Button.cancel()]
        )
    }
    
    @ViewBuilder
    private func remindMeSection() -> some View {
        if eventStore.accessGranted {
            Section {
                ForEach(EventStore.components, id: \.self) { component in
                    Button {
                        Ory.withHapticsAndAnimation {
                            story.remindMeNext(component, eventStore: eventStore, context: context)
                        }
                    } label: {
                        Label("Remind me \(component.str)", systemImage: "bell")
                    }
                }
            }
        }
    }
}

private let storyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

fileprivate struct StoryListRowView_Testing: View {
    @State private var activeURL: URL?
    
    var body: some View {
        NavigationView {
            List(0..<SampleData.texts.count) { index in
                StoryListRowView(story: SampleData.story(storyIndex: index))
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StoryRowView_Previews: PreviewProvider {
    static var previews: some View {
        StoryListRowView_Testing()
            .preferredColorScheme(.dark)
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .environmentObject(Filter())
            .environmentObject(EventStore())
            .previewLayout(.fixed(width: 350, height: 800))
    }
}
