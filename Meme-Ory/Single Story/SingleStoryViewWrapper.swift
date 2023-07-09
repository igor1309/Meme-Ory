//
//  SingleStoryViewWrapper.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SingleStoryComponent
import SwiftUI

struct SingleStoryWrapperView<Story, SingleStoryToolbar, SingleStoryView, TagListButton, BottomView>: View
where SingleStoryToolbar: View,
      SingleStoryView: View,
      TagListButton: View,
      BottomView: View {
    
    let story: Story
    let singleStoryToolbar: (Story) -> SingleStoryToolbar
    let singleStoryView: (Story) -> SingleStoryView
    let bottomView: () -> BottomView
    let tagListButton: (Story) -> TagListButton
    
    var body: some View {
        VStack(spacing: 16) {
            singleStoryToolbar(story)
            singleStoryView(story)
            tagListButton(story)
            bottomView()
        }
        .padding([.top, .horizontal])
        .background(Color(UIColor.secondarySystemGroupedBackground).ignoresSafeArea())
    }
}
