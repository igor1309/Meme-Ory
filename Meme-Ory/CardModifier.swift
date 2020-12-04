//
//  CardModifier.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 03.12.2020.
//

import SwiftUI

struct CardModifier: ViewModifier {
    var padding: CGFloat? = nil
    var strokeBorderColor: Color = Color(UIColor.systemGray3)
    
    func body(content: Content) -> some View {
        content
            .padding(.all, padding == nil ? .none : padding)
            .background(
                Color.primary.opacity(0.05)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(strokeBorderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

extension View {
    func cardModifier(padding: CGFloat? = nil, strokeBorderColor: Color = Color(UIColor.systemGray3)) -> some View {
        self.modifier(CardModifier(padding: padding, strokeBorderColor: strokeBorderColor))
    }
}

