//
//  CardModifier.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 03.12.2020.
//

import SwiftUI

extension View {
    func cardModifier<Background: View>(padding: CGFloat? = nil,
                                        cornerRadius: CGFloat = 16,
                                        strokeBorderColor: Color = Color(UIColor.systemGray3),
                                        background: Background) -> some View {
        self.modifier(
            CardModifier(padding: padding,
                         cornerRadius: cornerRadius,
                         strokeBorderColor: strokeBorderColor,
                         background: background
            )
        )
    }
}

fileprivate struct CardModifier<Background: View>: ViewModifier {
    let padding: CGFloat?
    var cornerRadius: CGFloat
    var strokeBorderColor: Color
    let background: Background
    
    func body(content: Content) -> some View {
        content
            .padding(.all, padding == nil ? .none : padding)
            .background(background)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(strokeBorderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

