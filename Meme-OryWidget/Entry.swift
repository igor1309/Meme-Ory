//
//  Entry.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 25.11.2020.
//

import WidgetKit

struct Entry: TimelineEntry {
    var date: Date
    var stories: [Story]
}

extension Entry {
    static var sampleEmpty = Entry(date: Date(), stories: [])
    static var sampleOneStory = Entry(date: Date(), stories: [SampleData.story(storyIndex: 6)])
    static var sampleTwoStories = Entry(date: Date(), stories: [SampleData.story(storyIndex: 8), SampleData.story(storyIndex: 6)])
    static var sampleMany = Entry(date: Date(), stories: [SampleData.story(), SampleData.story(storyIndex: 8), SampleData.story(storyIndex: 12), SampleData.story(), SampleData.story(storyIndex: 2), SampleData.story()])
}
