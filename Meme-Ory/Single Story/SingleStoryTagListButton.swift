//
//  SingleStoryTagListButton.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 12.06.2023.
//

import SwiftUI

struct SingleStoryTagListButton: View {
    
    let tagList: String
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
}

struct SingleStoryTagListButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SingleStoryTagListButton(tagList: "no tags", action: {})
            SingleStoryTagListButton(tagList: "joke, irony", action: {})
        }
    }
}
