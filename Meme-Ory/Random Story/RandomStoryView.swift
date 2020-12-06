//
//  RandomStoryView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 03.12.2020.
//

import SwiftUI
import CoreData

struct RandomStoryViewWrapper: View {
    
    @StateObject var model: RandomStoryViewModel
    
    init(context: NSManagedObjectContext) {
        _model = StateObject(wrappedValue: RandomStoryViewModel(context: context))
    }
    
    var body: some View {
        Group {
            if let story = model.randomStory {
                RandomStoryView(model: model, story: story)
            } else {
                VStack(spacing: 32) {
                    Text(model.title)
                        .foregroundColor(.secondary)
                    
                    Button("Show Random Story", action: model.getRandomStory)
                }
            }
        }
        .onAppear(perform: model.getRandomStory)
    }
}

struct RandomStoryView: View {
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var filter: Filter
    @EnvironmentObject private var eventStore: EventStore
    
    @ObservedObject var model: RandomStoryViewModel
    @ObservedObject var story: Story
    
    let cardBackground = Color(UIColor.tertiarySystemBackground).opacity(0.2)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                ScrollView(showsIndicators: false) {
                    Text(story.text)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
                .cardModifier(strokeBorderColor: Color(UIColor.systemGray3), background: cardBackground)
                .contentShape(Rectangle())
                .gesture(tapGesture)
                
                HStack(alignment: .top) {
                    Button(action: model.showTagGrid) {
                        Text(story.tagList)
                            .foregroundColor(Color(UIColor.systemOrange))
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    
                    Spacer()
                    
                    HStack {
                        favoriteIcon()
                        reminderIcon()
                    }
                    .imageScale(.small)
                    .cardModifier(padding: 9, cornerRadius: 9, background: cardBackground)
                }
                
                Text("Double tap to get next random story")
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .font(.caption)
            }
            .padding([.top, .horizontal])
            .background(Color(UIColor.secondarySystemGroupedBackground).ignoresSafeArea())
            .navigationBarTitle("Random Story", displayMode: .inline)
            .navigationBarItems(leading: listButton(), trailing: menu())
            .sheet(item: $model.sheetIdentifier, content: modalView)
            .actionSheet(isPresented: $showingDeleteConfirmation, content: confirmationActionSheet)
        }
        .onAppear(perform: model.getRandomStory)
        .onDisappear(perform: context.saveContext)
        .onOpenURL(perform: model.handleOpenURL)
    }
    
    
    //  MARK: Icons
    
    @ViewBuilder
    private func favoriteIcon() -> some View {
        Image(systemName: story.isFavorite ? "star.fill" : "star")
            .foregroundColor(story.isFavorite ? Color(UIColor.systemOrange) : Color(UIColor.systemBlue))
    }
    
    @ViewBuilder
    private func reminderIcon() -> some View {
        Image(systemName: story.hasReminder ? "bell" : "bell.slash")
            .foregroundColor(story.hasReminder ? Color(UIColor.systemTeal) : .secondary)
    }
    
    
    //  MARK: Modal View
    
    @ViewBuilder
    private func modalView(sheetIdentifier: RandomStoryViewModel.SheetIdentifier) -> some View {
        switch sheetIdentifier.id {
            case .tags:
                TagsWrapperWrapper(story: story)
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
                NavigationView {
                    StoryEditorView(story: story)
                }
                .environment(\.managedObjectContext, context)
                .environmentObject(eventStore)
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
            StoryActionButtons(model: model, story: story, showingDeleteConfirmation: $showingDeleteConfirmation, labelStyle: .none)
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
    
    
    //  MARK: Douple Tap Gesture
    
    var tapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded(model.getRandomStory)
    }
}


struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        RandomStoryViewWrapper(context: SampleData.preview.container.viewContext)
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .environmentObject(EventStore())
            .environmentObject(Filter())
            .preferredColorScheme(.dark)
    }
}
