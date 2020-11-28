//
//  StoryToShow.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 28.11.2020.
//

import SwiftUI

struct StoryToShowURLKey: EnvironmentKey {
    static var defaultValue = URL(string: "https://www.apple.com")!
}

extension EnvironmentValues {
    var storyToShowURL: URL {
        get { self[StoryToShowURLKey.self] }
        set { self[StoryToShowURLKey.self] = newValue }
    }
}

extension View {
    func storyToShowURL(_ storyToShowURL: URL) -> some View {
        environment(\.storyToShowURL, storyToShowURL)
    }
}
