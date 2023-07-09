//
//  SingleStoryViewWrapper.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SingleStoryComponent
import SwiftUI

struct SingleStoryWrapperView<SingleStoryToolbar, SingleStoryView, TagListButton, BottomView>: View
where SingleStoryToolbar: View,
      SingleStoryView: View,
      TagListButton: View,
      BottomView: View {
    
    let singleStoryToolbar: () -> SingleStoryToolbar
    let singleStoryView: () -> SingleStoryView
    let bottomView: () -> BottomView
    let tagListButton: () -> TagListButton
    
    var body: some View {
        VStack(spacing: 16) {
            singleStoryToolbar()
            singleStoryView()
            tagListButton()
            bottomView()
        }
        .padding([.top, .horizontal])
        .background(
            Color(UIColor.secondarySystemGroupedBackground)
                .ignoresSafeArea()
        )
    }
}
