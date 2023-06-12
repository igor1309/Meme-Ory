//
//  StoryListRowView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 12.06.2023.
//

import SwiftUI

struct StoryListRowView: View {
    
    let text: String
    let tagList: String
    let timestamp: Date
    let hasReminder: Bool
    let isFavorite: Bool
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 3) {
                text.storyText(maxTextLength: 1_000)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(20)
                
                if !tagList.isEmpty {
                    Label {
                        Text(tagList)
                    } icon: {
                        Image(systemName: "tag")
                            .imageScale(.small)
                    }
                    .foregroundColor(.orange)
                    .font(.caption)
                }
                
                Text("\(timestamp, formatter: Ory.storyFormatter)")
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .font(.caption)
            }
            
            HStack {
                if hasReminder {
                    Image(systemName: "bell")
                        .foregroundColor(Color(UIColor.systemTeal))
                    
                }
                
                if isFavorite {
                    Image(systemName: "star.circle")
                        .foregroundColor(Color(UIColor.systemOrange))
                }
            }
            .font(.caption)
        }
        .padding(.vertical, 3)
    }
}
