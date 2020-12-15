//
//  MainView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 13.12.2020.
//

import SwiftUI
import CoreData


//  MARK: - Main View

struct MainView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var eventStore: EventStore
    @EnvironmentObject private var model: MainViewModel
    
    @FetchRequest var stories: FetchedResults<Story>
    
    init(fetchRequest: NSFetchRequest<Story>) {
        _stories = FetchRequest(fetchRequest: fetchRequest)
    }
    
    var body: some View {
        viewSwither()
            .navigationTitle(model.viewMode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbar)
            .sheet(item: $model.sheetID, content: sheetView)
    }
    
    
    //  MARK: - Views
    
    @ViewBuilder
    private func viewSwither() -> some View {
        if stories.isEmpty {
            noStoriesView()
        } else {
            switch model.viewMode {
                case .single:
                    oneStoryUI()
                case .list:
                    StoryListView(stories: _stories)
            }
        }
    }
    
    @ViewBuilder
    private func oneStoryUI() -> some View {
        if let story = stories.first {
            SingleStoryView(story: story)
        } else {
            Text("ERROR: can't get first story from nnon-empty array")
        }
        
    }
    
    private func noStoriesView() -> some View {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(UIColor.secondarySystemGroupedBackground)
                .ignoresSafeArea(.all)
        )
    }
    
    
    //  MARK: - Sheets
    
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
                    ListOptionsView(model: model)
                    
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
    
    
    //  MARK: - Toolbar
    
    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            if !stories.isEmpty {
                Menu {
                    MainViewActionButtons(stories: Array(stories))
                } label: {
                    Image(systemName: "ellipsis.circle")
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
