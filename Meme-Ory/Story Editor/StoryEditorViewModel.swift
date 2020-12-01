//
//  StoryEditorViewModel.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 29.11.2020.
//

import SwiftUI
import Combine

final class StoryEditorViewModel: ObservableObject {
    @Published var text: String
    @Published var tags: Set<Tag>
    @Published var isFavorite: Bool
    @Published var calendarItemIdentifier: String
    @Published var mode: Mode
    
    @Published var hasChanges: Bool = false
    
    enum Mode {
        case create, edit
        
        var title: String {
            switch self {
                case .edit:
                    return ""
                case .create:
                    return "New"
            }
        }
    }
    
    init() {
        text = ""
        tags = []
        isFavorite = false
        calendarItemIdentifier = ""
        mode = .create
        
        subscribeToChanges()
    }
    
    init(text: String, tags: Set<Tag>, isFavorite: Bool, calendarItemIdentifier: String) {
        self.text = text
        self.tags = tags
        self.isFavorite = isFavorite
        self.calendarItemIdentifier = calendarItemIdentifier
        self.mode = .edit
        
        subscribeToChanges()
    }
    
    private func subscribeToChanges() {
        Publishers.CombineLatest(
            Publishers.CombineLatest(
                $text,
                $tags
            ),
            Publishers.CombineLatest3(
                $mode,
                $isFavorite,
                $calendarItemIdentifier
            )
        )
        .dropFirst()
        .throttle(for: 0.5, scheduler: RunLoop.main, latest: true)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            print("StoryEditorViewModel: model changed")
            self?.hasChanges = true
        }
        .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellables {
            cancell.cancel()
        }
    }
}
