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
    
    @EnvironmentObject private var eventStore: EventStore
    
    @ObservedObject var story: Story
    
    @Binding var filter: Filter
    
    let remindersAccessGranted: Bool
    
    private let components: [Calendar.Component] = [.day, .weekOfYear, .month, .year]
    
    @State private var showStorySheet = false
    
    var reminder: EKReminder? {
        EKEventStore().calendarItem(withIdentifier: story.calendarItemIdentifier) as? EKReminder
    }
    
    var body: some View {
        Button {
            withAnimation {
                showStorySheet = true
            }
        } label: {
            label
        }
        .onAppear(perform: reminderCleanUp)
        .onOpenURL(perform: handleURL)
        .accentColor(.primary)
        .contentShape(Rectangle())
        .sheet(isPresented: $showStorySheet) {
            StoryEditorView(story: story, remindersAccessGranted: eventStore.accessGranted)
                .environment(\.managedObjectContext, context)
        }
    }
    
    var label: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading) {
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
            .padding(.vertical, 3)
            
            if story.isFavorite {
                ZStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(Color(UIColor.systemBackground))
                        .imageScale(.large)
                    Image(systemName: "star.circle")
                        .foregroundColor(Color(UIColor.systemYellow))
                }
            }
        }
        .contextMenu {
            /// toggle favotite
            toggleFavoriteButton()
            /// copy story text
            copyStoryTextButton()
            /// share sheet
            shareStorySection()
            /// setting reminders
            remindMeButton()
            //remindMeSection()
            /// if story has just one tag - filter by this tag
            filterByTagSection()
        }
        .actionSheet(isPresented: $showRemindMeActionSheet, content: remindMeActionSheet)
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
    
    private func shareStorySection() -> some View {
        /// https://www.hackingwithswift.com/articles/118/uiactivityviewcontroller-by-example
        
        Section {
            Button {
                let items = [story.text]
                let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
            } label: {
                Label("Share story text", systemImage: "square.and.arrow.up")
            }
            
            Button {
                //let items = [story.url]
                let items: [Any] = [story.text, story.url]
                let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
                
            } label: {
                Label("Share with link", systemImage: "square.and.arrow.up.on.square")
            }
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
        let remindingButtons = components.map { component in
            ActionSheet.Button.default(Text("\(component.str)")) {
                let haptics = Haptics()
                haptics.feedback()
                
                withAnimation {
                    remindMeNext(component)
                }
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
        if remindersAccessGranted {
            Section {
                ForEach(components, id: \.self) { component in
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
        if remindersAccessGranted {
            // if story has a pointer to the  reminder but reminder was deleted, clear the pointer
            if reminder == nil && story.calendarItemIdentifier_ != nil {
                story.calendarItemIdentifier_ = nil
                
                context.saveContext()
            }
        }
    }
    
    private func handleURL(_ url: URL) {
        //  MARK: - FINISH THIS
        /// check that it's correct url
        guard url.isStoryURL else { return }
        /// close sheet with story if it's open
        showStorySheet = false
        
        if story.url == url {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
                withAnimation {
                    showStorySheet = true
                }
            }
        }
    }
    
    //  MARK: - FINISH THIS
    // next month: next month 1st day
    // next weeek: next monday
    // next year: next Jan 1
    //
    private func remindMeNext(_ component: Calendar.Component, at hour: Int = 9) {
        let store = EKEventStore()
        //  MARK: - FINISH THIS
        //  add option to select calendar?
        //  https://nemecek.be/blog/16/how-to-use-ekcalendarchooser-in-swift-to-let-user-select-calendar-in-ios
        //
        guard let ekCalendar = store.defaultCalendarForNewReminders() else { return }
        
        var nextComponent = DateComponents()
        nextComponent.setValue(1, for: component)
        
        let calendar = Calendar(identifier: .gregorian)
        let nextDate = calendar.date(byAdding: nextComponent, to: Date())!
        var nextComponents = Calendar.current.dateComponents(Set(components), from: nextDate)
        nextComponents.hour = hour
        
        let newReminder = EKReminder(eventStore: store)
        newReminder.calendar = ekCalendar
        newReminder.title = story.text
        newReminder.dueDateComponents = nextComponents
        
        // let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        // newReminder.notes = "created by \(appName)"
        
        //  MARK: setting url property has no effect
        //  known bug
        //  https://developer.apple.com/forums/thread/128140
        newReminder.url = story.url
        //  that's why write to notes
        newReminder.notes = story.url.absoluteString
        
        // delete existing reminder first - only one reminder
        // otherwise can't track reminders from stories
        if let reminder = reminder {
            do {
                try store.remove(reminder, commit: true)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        try! store.save(newReminder, commit: true)
        
        story.calendarItemIdentifier = newReminder.calendarItemIdentifier
        context.saveContext()
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
            List(0..<SampleData.texts.count) { index in
                StoryListRowView(story: SampleData.story(storyIndex: index), filter: $filter, remindersAccessGranted: true)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StoryRowView_Previews: PreviewProvider {
    static var previews: some View {
        StoryListRowView_Testing()
            .preferredColorScheme(.dark)
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .previewLayout(.fixed(width: 350, height: 800))
    }
}
