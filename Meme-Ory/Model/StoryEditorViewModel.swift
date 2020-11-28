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
    
    init() {
        text = ""
        tags = []
        isFavorite = false
    }
    
    init(text: String, tags: Set<Tag>, isFavorite: Bool) {
        self.text = text
        self.tags = tags
        self.isFavorite = isFavorite
    }
}
