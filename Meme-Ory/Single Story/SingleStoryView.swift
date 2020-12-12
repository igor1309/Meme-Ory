//
//  SingleStoryView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 03.12.2020.
//

import SwiftUI
import CoreData

struct SingleStoryViewWrapper: View {
    
    @StateObject var model: SingleStoryViewModel
    
    init(context: NSManagedObjectContext) {
        _model = StateObject(wrappedValue: SingleStoryViewModel(context: context))
    }
    
    var body: some View {
        Group {
            if let story = model.randomStory {
                SingleStoryView(model: model, story: story)
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

struct SingleStoryView: View {
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var filter: Filter
    @EnvironmentObject private var eventStore: EventStore
    
    @ObservedObject var model: SingleStoryViewModel
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
            //.background(Color(UIColor.secondarySystemGroupedBackground).ignoresSafeArea())
            .navigationBarTitle("Random Story", displayMode: .inline)
            .navigationBarItems(leading: listButton(), trailing: menu())
            .sheet(item: $model.sheetID, content: modalView)
            .actionSheet(item: $model.actionSheetID, content: actionSheet)
        }
        .onAppear(perform: model.getRandomStory)
        .onDisappear(perform: context.saveContext)
        //.onOpenURL(perform: model.handleOpenURL)
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
    private func modalView(sheetID: SingleStoryViewModel.SheetID) -> some View {
        switch sheetID {
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
                
            case .new:
                NavigationView {
                    StoryEditorView()
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
            StoryActionButtons(model: model, story: story, labelStyle: .none)
        } label: {
            Label("Story Actions", systemImage: "ellipsis.circle")
                .labelStyle(IconOnlyLabelStyle())
                .frame(width: 44, height: 44, alignment: .trailing)
        }
    }
    
    
    //  MARK: Action Sheets
    
    private func actionSheet(actionActionSheetID: SingleStoryViewModel.ActionSheetID) -> ActionSheet {
        switch actionActionSheetID {
            case .delete:
                return confirmationActionSheet()
            case .remindMe:
                return eventStore.remindMeActionSheet(for: story, in: context)
        }
    }

    private func confirmationActionSheet() -> ActionSheet {
        ActionSheet(
            title: Text("Delete Story?".uppercased()),
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
    @State static private var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        Group {
            SingleStoryView(model: SingleStoryViewModel(context: context), story: SampleData.story())
            
            SingleStoryViewWrapper(context: context)
                .previewLayout(.fixed(width: 350, height: 200))
        }
        .environment(\.managedObjectContext, context)
        .environmentObject(EventStore())
        .environmentObject(Filter())
        .preferredColorScheme(.dark)
    }
}
