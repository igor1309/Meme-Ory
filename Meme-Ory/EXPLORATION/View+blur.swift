//
//  View+blur.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 02.01.2024.
//

import SwiftUI

extension View {
    
    func blur(style: UIBlurEffect.Style) -> some View {
        
        background(BlurView(style: style))
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
