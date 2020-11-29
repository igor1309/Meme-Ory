//
//  StoryEditorViewModel.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 29.11.2020.
//

import SwiftUI

final class StoryEditorViewModel: ObservableObject {
    @Published var text: String
    @Published var tags: Set<Tag>
    @Published var isFavorite: Bool
    @Published var calendarItemIdentifier: String
    
    init() {
        text = ""
        tags = []
        isFavorite = false
        calendarItemIdentifier = ""
    }
    
    init(text: String, tags: Set<Tag>, isFavorite: Bool, calendarItemIdentifier: String) {
        self.text = text
        self.tags = tags
        self.isFavorite = isFavorite
        self.calendarItemIdentifier = calendarItemIdentifier
    }
}
