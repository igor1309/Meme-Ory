//
//  SingleStoryViewWrapper.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SingleStoryComponent
import SwiftUI

struct SingleStoryViewWrapper: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var model: MainViewModel
    @EnvironmentObject private var eventStore: EventStore
    
    @ObservedObject var story: Story
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Button("Switch to List") {
                    model.switchViewMode()
                }

                Spacer()
                
                Group {
                    favoriteIcon()
                    reminderIcon()
                }
                .imageScale(.small)
                // .cardModifier(padding: 9, cornerRadius: 9, background: cardBackground)
            }
            
            SingleStoryView(
                text: story.text,
                maxTextLength: maxTextLength
            )
            .contentShape(Rectangle())
            .onTapGesture(count: 1, perform: model.getRandomStory)
            
            HStack(alignment: .top) {
                Button {
                    model.showTagGrid(story: story)
                } label: {
                    Text(story.tagList)
                        .foregroundColor(Color(UIColor.systemOrange))
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                
                Spacer()
                
                //                HStack {
                //                    favoriteIcon()
                //                    reminderIcon()
                //                }
                //                .imageScale(.small)
                //                .cardModifier(padding: 9, cornerRadius: 9, background: cardBackground)
            }
            
            Text("Tap card to get next random story")
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .font(.caption)
        }
        .padding([.top, .horizontal])
        .background(Color(UIColor.secondarySystemGroupedBackground).ignoresSafeArea())
        .toolbar(content: toolbar)
        .actionSheet(item: $model.actionSheetID, content: actionSheet)
        .onAppear(perform: handleOnApper)
    }
    
    private func handleOnApper() {
        eventStore.reminderCleanup(for: story, in: context)
    }

    //  MARK: - Constants
    
    let maxTextLength = 5_000
    let cardBackground = Color(UIColor.tertiarySystemBackground).opacity(0.2)

    //  MARK: - Icons
    
    @ViewBuilder
    private func favoriteIcon() -> some View {
        Image(systemName: story.isFavorite ? "star.fill" : "star")
            .foregroundColor(story.isFavorite ? Color(UIColor.systemOrange) : .secondary)
    }
    
    @ViewBuilder
    private func reminderIcon() -> some View {
        Image(systemName: story.hasReminder ? "bell.fill" : "bell.slash")
            .foregroundColor(story.hasReminder ? Color(UIColor.systemTeal) : .secondary)
    }
    
    //  MARK: - Toolbar
    
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                StoryActionButtons(story: story)
            } label: {
                Image(systemName: "doc.plaintext")
                    .frame(width: 44, height: 44, alignment: .trailing)
            }
        }
    }    
    
    //  MARK: - Action Sheets
    
    private func actionSheet(actionSheetID: MainViewModel.ActionSheetID) -> ActionSheet {
        switch actionSheetID {
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
                .destructive(Text("Yes, delete!")) { model.delete(story: story) },
                .cancel()
            ]
        )
    }
    
}

struct SingleStoryView_Previews: PreviewProvider {
    @State static var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        NavigationView {
            SingleStoryViewWrapper(story: SampleData.story())
                .navigationTitle("Random/Widget Story")
                .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.managedObjectContext, context)
        .environmentObject(MainViewModel(context: context))
        .environmentObject(EventStore())
        .environment(\.sizeCategory, .large)
        .environment(\.colorScheme, .dark)
        .previewLayout(.fixed(width: 350, height: 700))
    }
}