//
//  SingleStoryTagListButton.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 12.06.2023.
//

import SwiftUI

struct SingleStoryTagListButton: View {
    
    let story: Story
    let action: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            Button(action: action) {
                Text(tagList)
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
    }
    
    var tagList: String {
        if story.tags.isEmpty {
            return "no tags"
        } else {
            return story.tagList
        }
    }
}

struct SingleStoryTagListButton_Previews: PreviewProvider {
    static var previews: some View {
        SingleStoryTagListButton(story: .preview, action: {})
    }
}
