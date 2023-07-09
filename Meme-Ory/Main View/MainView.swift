//
//  MainView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 13.12.2020.
//

import SwiftUI
import CoreData
import SingleStoryComponent


// MARK: - Main View

struct MainView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var eventStore: EventStore
    @EnvironmentObject private var model: MainViewModel
    
    @FetchRequest var stories: FetchedResults<Story>

    private let maxTextLength = 5_000

    init(fetchRequest: NSFetchRequest<Story>) {
        _stories = FetchRequest(fetchRequest: fetchRequest)
    }
    
    var body: some View {
        viewSwitcher()
            .navigationTitle(model.viewMode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbar)
            .sheet(item: $model.sheetID, content: sheetView)
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private func viewSwitcher() -> some View {
        if stories.isEmpty {
            noStoriesView()
        } else {
            switch model.viewMode {
            case .single:
                oneStoryUI()
            case .list:
                storyListView()
            }
        }
    }
    
    private func noStoriesView() -> some View {
        Color(UIColor.secondarySystemGroupedBackground)
            .ignoresSafeArea(.all)
            .overlay(
                VStack(spacing: 16) {
                    Text("No Saved Stories")
                    Text("Add stories from other apps via share sheet or directly")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .padding(.bottom)
                    
                    Button("Add Story") {
                        model.createNewStory()
                    }
                    
                    Button("Paste Clipboard to New Story") {
                        model.pasteToNewStory()
                    }
                }
                    .padding()
            )
    }
    
    @ViewBuilder
    private func oneStoryUI() -> some View {
        if let story = stories.first {
            singleStoryView(story: story)
        } else {
            Text("ERROR: can't get first story from non-empty array")
        }
    }
    
    private func singleStoryView(story: Story) -> some View {
        
        SingleStoryWrapperView(
            singleStoryToolbar: {
                SingleStoryToolbar(
                    isFavorite: story.isFavorite,
                    hasReminder: story.hasReminder,
                    switchViewMode: model.switchViewMode
                )
            },
            singleStoryView: {
                SingleStoryView(
                    text: story.text,
                    maxTextLength: maxTextLength
                )
                .contentShape(Rectangle())
                .onTapGesture(count: 1, perform: model.getRandomStory)
            },
            bottomView: {
                Text("Tap on the card to get next random story.")
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .font(.caption)
            },
            tagListButton: {
                SingleStoryTagListButton(
                    tagList: story.tags.isEmpty ? "no tags" : story.tagList
                ) {
                    model.showTagGrid(story: story)
                }
            }
        )
        .onAppear {
            eventStore.reminderCleanup(
                for: story,
                in: context
            )
        }
        .actionSheet(item: $model.actionSheetID) {
            actionSheet(actionSheetID: $0, story: story)
        }
        .toolbar { singleStoryToolbar(story: story) }
    }
    
    // MARK: Story List
    
    private func storyListView() -> some View {
        StoryListView(
            stories: _stories,
            storyListRowView: storyListRowView,
            confirmDelete: confirmDelete
        )
        .toolbar(content: storyListViewToolbar)
        .sheet(
            item: $model.sheetID,
            content: storyListViewSheet
        )
        .actionSheet(
            item: $model.actionSheetID,
            content: storyListViewActionSheet
        )
    }
    
    private func storyListRowView(story: Story) -> some View {
        
        StoryListRowViewWrapper(story: story)
            .contentShape(Rectangle())
            .contextMenu {
                ListRowActionButtons(story: story)
            }
            .onAppear {
                eventStore.reminderCleanup(
                    for: story,
                    in: context
                )
            }
    }

    private func storyListViewToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                ListActionButtons()
            } label: {
                Image(systemName: "list.bullet")
                    .frame(width: 44, height: 44, alignment: .trailing)
                    .if(model.listOptions.isActive) { $0.foregroundColor(Color(UIColor.systemOrange)) }
            }
        }
    }
    
    @ViewBuilder
    private func storyListViewSheet(
        sheetID: MainViewModel.SheetID
    ) -> some View {
        switch sheetID {
        case .listOptions:
            NavigationView {
                ListOptionsView(
                    model: model,
                    resetTags: {
                        model.listOptions.resetTags()
                        model.dismissSheet()
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Done", action: model.dismissSheet)
                    }
                }
            }
            
        default: Text("TBD")
        }
    }
    
    private func storyListViewActionSheet(
        actionSheetID: MainViewModel.ActionSheetID
    ) -> ActionSheet {
        switch actionSheetID {
        case .remindMe:
            if let storyToEdit = model.storyToEdit {
                return eventStore.remindMeActionSheet(for: storyToEdit, in: context)
            } else {
                return ActionSheet(title: Text("ERROR getting story"))
            }
            
        case .delete:
            return ActionSheet(
                title: Text("Delete Story?".uppercased()),
                message: Text("Are you sure? This cannot be undone."),
                buttons: [
                    .destructive(Text("Yes, delete!"), action: delete),
                    .cancel()
                ]
            )
        }
    }
    
    private func confirmDelete(_ indexSet: IndexSet) {
        self.indexSet = indexSet
        model.deleteStoryAction()
    }
    
    @State private var indexSet = IndexSet()
    
    private func delete() {
        Ory.withHapticsAndAnimation {
            for index in self.indexSet {
                self.context.delete(self.stories[index])
            }
            
            self.context.saveContext()
        }
    }

    // MARK: - Action Sheets
    
    private func actionSheet(
        actionSheetID: MainViewModel.ActionSheetID,
        story: Story
    ) -> ActionSheet {
        
        switch actionSheetID {
        case .delete:
            return confirmationActionSheet(story: story)
        case .remindMe:
            return eventStore.remindMeActionSheet(for: story, in: context)
        }
    }
    
    private func confirmationActionSheet(
        story: Story
    ) -> ActionSheet {
        
        .init(
            title: Text("Delete Story?".uppercased()),
            message: Text("Are you sure? This cannot be undone."),
            buttons: [
                .destructive(Text("Yes, delete!")) { model.delete(story: story) },
                .cancel()
            ]
        )
    }
    
    // MARK: - Toolbar
    
    private func singleStoryToolbar(
        story: Story
    ) -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                StoryActionButtons(model: model, story: story)
            } label: {
                Image(systemName: "doc.plaintext")
                    .frame(width: 44, height: 44, alignment: .trailing)
            }
        }
    }
    
    // MARK: - Sheets
    
    @ViewBuilder
    private func sheetView(sheetID: MainViewModel.SheetID) -> some View {
        Group {
            switch sheetID {
            case .new:
                NavigationView {
                    StoryEditorView()
                }
                
            case .edit:
                if let storyToEdit = model.storyToEdit {
                    NavigationView {
                        StoryEditorView(story: storyToEdit)
                    }
                    .environment(\.managedObjectContext, context)
                    .environmentObject(eventStore)
                } else {
                    Text("ERROR getting story to edit")
                }
                
            case .tags:
                if let storyToEdit = model.storyToEdit {
                    TagsWrapperWrapper(story: storyToEdit)
                        .environment(\.managedObjectContext, context)
                } else {
                    Text("ERROR getting story to show tags")
                }
                
            case .maintenance:
                MaintenanceView(context: context)
                
            case .listOptions:
                NavigationView {
                    ListOptionsView(
                        model: model,
                        resetTags: {
                            model.listOptions.resetTags()
                            model.dismissSheet()
                        }
                    )
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Done", action: model.dismissSheet)
                        }
                    }
                }
                
            case let .story(url):
                //                    if let story = context.getObject(with: url) as? Story {
                if let story: Story = context.getObject(with: url) {
                    ScrollView {
                        Text(story.text)
                            .padding()
                    }
                } else {
                    Text("Error getting Story from URL")
                }
                
            case let .file(url):
                ImportTextView(url: url)
                    .environment(\.managedObjectContext, context)
            }
        }
        .environment(\.managedObjectContext, context)
        .environmentObject(eventStore)
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            if !stories.isEmpty {
                Menu {
                    MainViewActionButtons(stories: Array(stories))
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(width: 44, height: 44, alignment: .leading)
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    @State static var context = SampleData.preview.container.viewContext
    static let request = Story.fetchRequest(.all, sortDescriptors: [])
    
    static var previews: some View {
        Group {
            MainView(fetchRequest: request)
                .environmentObject(MainViewModel(context: context, viewMode: .list))
            
            MainView(fetchRequest: request)
                .environmentObject(MainViewModel(context: context))
        }
        .environment(\.managedObjectContext, context)
        .environmentObject(EventStore())
        .environmentObject(MainViewModel(context: context))
        .environment(\.colorScheme, .dark)
        .previewLayout(.fixed(width: 350, height: 500))
    }
}
