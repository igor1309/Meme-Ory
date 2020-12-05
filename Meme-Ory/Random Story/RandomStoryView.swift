//
//  RandomStoryView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 03.12.2020.
//

import SwiftUI
import CoreData

struct RandomStoryView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject private var filter: Filter
    @EnvironmentObject private var eventStore: EventStore
    
    @StateObject var model: RandomStoryViewModel
    
    init(context: NSManagedObjectContext) {
        _model = StateObject(wrappedValue: RandomStoryViewModel(context:context))
    }
    
    let cardBackground = Color(UIColor.tertiarySystemBackground).opacity(0.2)
    
    var body: some View {
        NavigationView {
            if let story = model.story {
                VStack {
                    VStack {
                        ScrollView(showsIndicators: false) {
                            Text(story.text)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                        .cardModifier(strokeBorderColor: Color(UIColor.systemGray3), background: cardBackground)
                        .contentShape(Rectangle())
                        .gesture(tapGesture)
                        
                        HStack(alignment: .top) {
                            Button(action: model.showTagGrid) {
                                Text(model.tagNames)
                                    .foregroundColor(Color(UIColor.systemOrange))
                                    .font(.caption)
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
                        
                        Text("Double tap to get next random story")
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .font(.caption)
                    }
                    .padding([.top, .horizontal])
                }
                .background(Color(UIColor.secondarySystemGroupedBackground).ignoresSafeArea())
                .navigationBarTitle("Random Story", displayMode: .inline)
                .navigationBarItems(leading: listButton(), trailing: menu())
                .sheet(item: $model.sheetIdentifier, content: modalView)
            } else {
                VStack(spacing: 32) {
                    Text(model.title)
                        .foregroundColor(.secondary)
                    
                    Button("Show Random Story") {
                        model.getRandomStory()
                    }
                }
            }
        }
        .onAppear(perform: { model.getRandomStory() })
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
    
    
    //  MARK: Handle Scene Phase
    
    private func handleScenePhase(scenePhase: ScenePhase) {
        if scenePhase == .background {
            context.saveContext()
        }
    }
    
    
    //  MARK: Handle OpenURL
    
    private func handleOpenURL(url: URL) {
        #if DEBUG
        //print("handleOpenURL: \(url)")
        #endif
        
        let haptics = Haptics()
        haptics.feedback()
        
        // withAnimation {
        model.storyURL = url
        // showingList = false
        // }
    }
    
    
    //  MARK: Modal View
    
    @ViewBuilder
    private func modalView(sheetIdentifier: RandomStoryViewModel.SheetIdentifier) -> some View {
        switch sheetIdentifier.id {
            case .tags:
                TagGridWrapperView(selected: $model.tags)
                    .environment(\.managedObjectContext, context)
                
            case .list:
                NavigationView {
                    StoryListView(filter: filter, showPasteButton: false)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .environment(\.managedObjectContext, context)
                .environmentObject(eventStore)
                .environmentObject(filter)
                
            case .edit:
                if let story = model.story {
                    NavigationView {
                        StoryEditorView(story: story)
                    }
                    .environment(\.managedObjectContext, context)
                    .environmentObject(eventStore)
                } else {
                    Text("Can't Edit this Story")
                }
        }
    }
    
    
    //  MARK: List Button
    
    private func listButton() -> some View {
        Button {
            model.showStoryList()
        } label: {
            Label("List", systemImage: "list.bullet")
                .labelStyle(IconOnlyLabelStyle())
                .frame(width: 44, height: 44, alignment: .leading)
        }
    }
    
    
    //  MARK: Menu
    
    @ViewBuilder
    private func menu() -> some View {
        Menu {
            StoryActionButtons(model: model, showingDeleteConfirmation: $showingDeleteConfirmation, labelStyle: .none)
        } label: {
            Label("Story Actions", systemImage: "ellipsis.circle")
                .labelStyle(IconOnlyLabelStyle())
                .frame(width: 44, height: 44, alignment: .trailing)
        }
    }
    
    
    //  MARK: Delete Story
    
    @State private var showingDeleteConfirmation = false
    
    private func confirmationActionSheet() -> ActionSheet {
        ActionSheet(
            title: Text("Delete Story?"),
            message: Text("Are you sure? This cannot be undone."),
            buttons: [
                .destructive(Text("Yes, delete!")) { model.deleteStory() },
                .cancel()
            ]
        )
    }
    
    
    //  MARK: Tap Gesture
    
    var tapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                model.getRandomStory()
            }
    }
}


struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        RandomStoryView(context: SampleData.preview.container.viewContext)
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .environmentObject(EventStore())
            .environmentObject(Filter())
            .preferredColorScheme(.dark)
    }
}
