//
//  StorySimpleView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

struct StorySimpleView: View {
    
    @Environment(\.presentationMode) private var presentation
    
    let text: String
    let tags: String
    let title: String
    
    init(text: String, title: String) {
        self.text = text
        self.tags = ""
        self.title = title
    }
    
    init(story: Story) {
        self.text = story.text
        self.tags = story.tagList
        self.title = "Story"
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text(tags)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.top, .horizontal])
                
                ScrollView {
                    text.storyText(maxTextLength: maxTextLength)
                        .padding(.horizontal)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentation.wrappedValue.dismiss()
                }
            )
        }
    }
    
    
    //  MARK: - Constants
    
    let maxTextLength = 5_000

}


struct StorySimpleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StorySimpleView(story: SampleData.story())

            StorySimpleView(text: "Some Text", title: "Some title")
        }
        .environment(\.colorScheme, .dark)
        .previewLayout(.fixed(width: 350, height: 500))
    }
}
