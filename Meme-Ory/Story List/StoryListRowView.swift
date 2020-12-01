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
    
    @Binding var activeURL: URL?
    
    @State private var showingStorySheet = false
    
    var body: some View {
        NavigationLink(
            destination: StoryEditorView(story: story),
            tag: story.url,
            selection: $activeURL
        ) {
            label
                .contextMenu {
                    /// toggle favotite
                    toggleFavoriteButton()
                    /// copy story text
                    copyStoryTextButton()
                    /// share sheet
                    ShareStoryView(text: story.text, url: story.url)
                    /// setting reminders
                    remindMeButton()
                    //remindMeSection()
                    /// if story has just one tag - filter by this tag
                    filterByTagSection()
                }
        }
        .contentShape(Rectangle())
        .onAppear(perform: reminderCleanUp)
        .onOpenURL(perform: handleURL)
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
    
    private func handleURL(url: URL) {
        withAnimation {
            guard let deeplink = url.deeplink,
                  case .story(let reference) = deeplink,
                  story.url == reference else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
                activeURL = url
            }
        }
    }
    
    var label: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 3) {
                Text(story.storyText())
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
            
            if story.isFavorite {
                Image(systemName: "star.circle")
                    .foregroundColor(Color(UIColor.systemOrange))
                    .imageScale(.small)
                    .offset(x: 24)
            }
        }
        .padding(.vertical, 3)
    }
    
    private func toggleFavoriteButton() -> some View {
        Button {
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
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
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                UIPasteboard.general.string = story.text
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
                        let haptics = Haptics()
                        haptics.feedback()
                        
                        withAnimation {
                            filter.tags = []
                        }
                    } label: {
                        Label("Reset tags", systemImage: "tag.slash")
                    }
                } else {
                    // set filter by this tag
                    Button {
                        let haptics = Haptics()
                        haptics.feedback()
                        
                        withAnimation {
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
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                showRemindMeActionSheet = true
            }
        } label: {
            Label("Remind me...", systemImage: "bell")
        }
    }
    
    private func remindMeActionSheet() -> ActionSheet {
        let remindingButtons = EventStore.components.map { component in
            ActionSheet.Button.default(Text("\(component.str)")) {
                remindMeNext(component)
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
                        let haptics = Haptics()
                        haptics.feedback()
                        
                        withAnimation {
                            remindMeNext(component)
                        }
                    } label: {
                        Label("Remind me \(component.str)", systemImage: "bell")
                    }
                }
            }
        }
    }
    
    private func reminderCleanUp() {
        //  reminder could be deleted from Reminders but Story still store reference (calendarItemIdentifier)
        if story.calendarItemIdentifier != "",
           eventStore.accessGranted {
            // if story has a pointer to the  reminder but reminder was deleted, clear the pointer
            let reminder = eventStore.reminder(for: story)
            if reminder == nil {
                story.calendarItemIdentifier_ = nil
                context.saveContext()
            }
        }
    }
    
    //  MARK: - FINISH THIS
    // next month: next month 1st day
    // next weeek: next monday
    // next year: next Jan 1
    //
    private func remindMeNext(_ component: Calendar.Component, hour: Int = 9) {
        guard eventStore.accessGranted,
              let calendarItemIdentifier = eventStore.addReminder(for: story, component: component, hour: hour) else { return }
        
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            story.calendarItemIdentifier = calendarItemIdentifier
            context.saveContext()
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
                StoryListRowView(story: SampleData.story(storyIndex: index), activeURL: $activeURL)
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