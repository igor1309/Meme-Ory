//
//  StoryView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 03.12.2020.
//

import SwiftUI
import CoreData

fileprivate struct StoryViewInternal: View {
    @ObservedObject var story: Story
    
    var body: some View {
        
    }
}

struct StoryView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject private var filter: Filter
    @EnvironmentObject private var eventStore: EventStore
    
    @State private var storyURL: URL?
    @State private var title = "no such story"
    
    @FetchRequest(
        sortDescriptors: []
    )
    var stories: FetchedResults<Story>
    
    private var story: Story? {
        context.getObject(with: storyURL) as? Story
    }
    
    @State private var sheetIdentifier: SheetIdentifier?
    
    //private
    struct SheetIdentifier: Identifiable {
        var id: Modal
        enum Modal { case list, tags }
    }
    
    let cardBackground = Color(UIColor.tertiarySystemBackground).opacity(0.2)
    
    var body: some View {
        NavigationView {
            if let story = story {
                VStack {
                    VStack(spacing: 0) {
                        ScrollView(showsIndicators: false) {
                            Text(story.text)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                        .cardModifier(strokeBorderColor: isDetectingGesture ? Color(UIColor.systemOrange) : Color(UIColor.systemGray3), background: cardBackground)
                        .contentShape(Rectangle())
                        .gesture(gesture)
                        
                        Button("Clear tags") {
                            story.tags = []
                        }
                        
                        HStack(alignment: .top) {
                            Button(action: showTagGrid) {
                                Text(tagNames)
                                    .foregroundColor(Color(UIColor.systemOrange))
                                    .font(.caption)
                                    .padding(.top, 6)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                            }
                            
                            Spacer()
                            
                            HStack {
                                favoriteIcon(story)
                                reminderIcon(story)
                            }
                            .imageScale(.small)
                            .cardModifier(padding: 9, cornerRadius: 9, background: cardBackground)
                        }
                        .padding(.top)
                        
                        Text("Double tap to get next random story")
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .font(.caption)
                    }
                    .padding()
                }
                .background(Color(UIColor.secondarySystemGroupedBackground).ignoresSafeArea())
                .navigationBarTitle("Randon Story", displayMode: .inline)
                .navigationBarItems(leading: listMenu(), trailing: menu())
                .sheet(item: $sheetIdentifier, content: modalView)
            } else {
                VStack(spacing: 32) {
                    Text(title)
                        .foregroundColor(.secondary)
                    
                    Button("Show Random Story") {
                        getRandomStory()
                    }
                }
            }
        }
        .onAppear(perform: getRandomStory)
        .onDisappear(perform: context.saveContext)
        .onChange(of: scenePhase, perform: handleScenePhase)
        .onOpenURL(perform: handleOpenURL)
        .actionSheet(isPresented: $showingDeleteConfirmation, content: confirmationActionSheet)
    }
    
    private func favoriteIcon(_ story: Story) -> some View {
        Image(systemName: story.isFavorite ? "star.fill" : "star")
            .foregroundColor(story.isFavorite ? Color(UIColor.systemOrange) : Color(UIColor.systemBlue))
    }
    
    private func reminderIcon(_ story: Story) -> some View {
        Image(systemName: story.hasReminder ? "bell" : "bell.slash")
            .foregroundColor(story.hasReminder ? Color(UIColor.systemTeal) : .secondary)
    }
    
    private func handleScenePhase(scenePhase: ScenePhase) {
        if scenePhase == .background {
            context.saveContext()
        }
    }
    
    private func getRandomStory() {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            storyURL = Story.oneRandom(in: context)?.url
        }
    }
    
    private func handleOpenURL(url: URL) {
        #if DEBUG
        //print("handleOpenURL: \(url)")
        #endif
        
        let haptics = Haptics()
        haptics.feedback()
        
        // withAnimation {
        storyURL = url
        // showingList = false
        // }
    }
    
    
    //  MARK: Tags Editing
    
    private var tagNames: String {
        story?.tags.map { $0.name }.joined(separator: ", ") ?? ""
    }
    
    private func showTagGrid() {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            sheetIdentifier = SheetIdentifier(id: .tags)
        }
    }
    

    //  MARK: Modal View
    
    @ViewBuilder
    private func modalView(sheetIdentifier: SheetIdentifier) -> some View {
        switch sheetIdentifier.id {
            case .tags:
                if let story = story {
                    TagsWrapperWrapper(story: story)
                        .environment(\.managedObjectContext, context)
                } else {
                    Text("Error editing tags")
                }
                
            case .list:
                NavigationView {
                    StoryListView(filter: filter, showPasteButton: false)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .environment(\.managedObjectContext, context)
                .environmentObject(eventStore)
                .environmentObject(filter)
        }
    }
    
    
    //  MARK: List Menu
    
    private func listMenu() -> some View {
        Button {
            sheetIdentifier = SheetIdentifier(id: .list)
        } label: {
            Label("List", systemImage: "list.bullet")
                .labelStyle(IconOnlyLabelStyle())
                .frame(width: 44, height: 44, alignment: .leading)
        }
    }
    
    
    //  MARK: Menu
    
    @ViewBuilder
    private func menu() -> some View {
        if let story = story {
            Menu {
                StoryActionButtons(story: story, storyURL: $storyURL, showingDeleteConfirmation: $showingDeleteConfirmation, sheetIdentifier: $sheetIdentifier, labelStyle: .none)
            } label: {
                Label("Story Actions", systemImage: "ellipsis.circle")
                    .labelStyle(IconOnlyLabelStyle())
                    .frame(width: 44, height: 44, alignment: .trailing)
            }
        }
    }
    
    
    //  MARK: Delete Story
    
    @State private var showingDeleteConfirmation = false
        
    private func confirmationActionSheet() -> ActionSheet {
        ActionSheet(
            title: Text("Delete Story?"),
            message: Text("Are you sure? This cannot be undone."),
            buttons: [
                .destructive(Text("Yes, delete!")) { deleteStory() },
                .cancel()
            ]
        )
    }
    
    private func deleteStory() {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            if let story = story {
                context.delete(story)
                context.saveContext()
                
                title = "Story was deleted"
            }
        }
    }
    

    //  MARK: Long Press and Tap Gesture
    
    @GestureState var isDetectingGesture = false
    
    var gesture: some Gesture {
        SimultaneousGesture(longPress, tapGesture)
    }
    
    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 1, maximumDistance: 10)
            .updating($isDetectingGesture) { currentstate, gestureState, transaction in
                gestureState = currentstate
                //                transaction.animation = Animation.easeIn(duration: 1)
            }
            .onEnded { finished in
                getRandomStory()
            }
    }
    
    var tapGesture: some Gesture {
        TapGesture(count: 2)
            .updating($isDetectingGesture) { _, _, _ in }
            .onEnded {
                getRandomStory()
            }
    }
}


struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView()
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .environmentObject(EventStore())
            .environmentObject(Filter())
            .preferredColorScheme(.dark)
    }
}
