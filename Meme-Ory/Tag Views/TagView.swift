//
//  TagView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

struct TagView: View {
    
    @ObservedObject var tag: Tag
    let isSelected: Bool
    
    let cornerRadius: CGFloat = 6
    
    var body: some View {
        Text(tag.name)
            .foregroundColor(isSelected ? Color(UIColor.systemOrange) : Color.secondary)
            .font(.footnote)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color(UIColor.systemFill) : Color(UIColor.secondarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(isSelected ? Color(UIColor.systemOrange) : Color(UIColor.systemGray3))
            )
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HStack {
                TagView(tag: SampleData.tag, isSelected: true)
                TagView(tag: SampleData.tag, isSelected: false)
            }
            .navigationBarTitle("Tags", displayMode: .inline)
        }
        .previewLayout(.fixed(width: 350, height: 300))
        .environment(\.colorScheme, .dark)
    }
}
