//
//  SingleStoryView.swift
//  
//
//  Created by Igor Malyarov on 12.06.2023.
//

import SwiftUI

struct SingleStoryView: View {
    
    let text: String
    let maxTextLength: Int?
    
    init(text: String, maxTextLength: Int? = nil) {
        self.text = text
        self.maxTextLength = maxTextLength
    }
    
    private let cardBackground = Color(UIColor.tertiarySystemBackground).opacity(0.2)
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            storyText(
                text: text,
                maxTextLength: maxTextLength
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .cardModifier(strokeBorderColor: Color(UIColor.systemGray3), background: cardBackground)
    }
    
    //  MARK: - Story Text View
    
    @ViewBuilder
    func storyText(
        text: String,
        maxTextLength: Int?
    ) -> some View {
        
        if let maxTextLength,
           text.count > maxTextLength {
            
            Text("Story too long, showing first \(maxTextLength) characters\n\n")
                .foregroundColor(Color(UIColor.systemRed))
                .font(.footnote)
            + Text(text.firstLinePrefix(maxedWith: maxTextLength))
        } else {
            Text(text)
        }
    }
}

struct SingleStoryView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        previewsGroup()
    }
    
    static func previewsGroup() -> some View {
        
        Group {
            SingleStoryView(text: .preview)
            SingleStoryView(
                text: .preview,
                maxTextLength: 100
            )
        }
        .padding()
    }
}
