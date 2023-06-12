//
//  SingleStoryViewWrapper.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SingleStoryComponent
import SwiftUI

struct SingleStoryViewWrapper: View {
    
    @EnvironmentObject private var model: MainViewModel
    
    @ObservedObject var story: Story
    
    var body: some View {
        VStack(spacing: 16) {
            
            SingleStoryToolbar(
                switchViewMode: model.switchViewMode,
                favoriteIcon: favoriteIcon,
                reminderIcon: reminderIcon
            )
            
            SingleStoryView(
                text: story.text,
                maxTextLength: maxTextLength
            )
            .contentShape(Rectangle())
            .onTapGesture(count: 1, perform: model.getRandomStory)
            
            SingleStoryTagListButton(story: story) {
                model.showTagGrid(story: story)
            }
            
            Text("Tap card to get next random story")
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .font(.caption)
        }
        .padding([.top, .horizontal])
        .background(Color(UIColor.secondarySystemGroupedBackground).ignoresSafeArea())
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
}

struct SingleStoryView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            SingleStoryViewWrapper(story: .preview)
                .navigationTitle("Random/Widget Story")
                .navigationBarTitleDisplayMode(.inline)
        }
        .environment(\.sizeCategory, .large)
        .environment(\.colorScheme, .dark)
        .previewLayout(.fixed(width: 350, height: 700))
    }
}

extension Story {
    
    static let preview: Story = SampleData.story()
}
