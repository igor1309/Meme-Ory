//
//  MyButton.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 03.12.2020.
//

import SwiftUI

struct MyButton: View {
    let title: String
    let icon: String
    let labelStyle: Style
    let withHaptics: Bool
    let useAnimation: Bool
    let action: () -> Void
    
    enum Style { case icon, title, none }
    
    init(title: String, icon: String, labelStyle: Style = .none, withHaptics: Bool = true, useAnimation: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.labelStyle = labelStyle
        self.withHaptics = withHaptics
        self.useAnimation = useAnimation
        self.action = action
    }
    
    // https://www.hackingwithswift.com/plus/intermediate-swiftui/customizing-label-using-labelstyle
    // https://www.swiftbysundell.com/articles/encapsulating-swiftui-view-styles/
    
    var body: some View {
        Button {
            if withHaptics {
                Ory.feedback()
            }
            
            if useAnimation {
                withAnimation {
                    action()
                }
            } else {
                action()
            }
        } label: {
            switch labelStyle {
                case .none: label().labelStyle(DefaultLabelStyle())
                case .title: label().labelStyle(TitleOnlyLabelStyle())
                case .icon: label().labelStyle(IconOnlyLabelStyle()).aspectRatio(1, contentMode: .fit)
            }
        }
    }
    
    private func label() -> some View {
        Label(title, systemImage: icon)
    }
}


struct MyButton_Previews: PreviewProvider {
    static var previews: some View {
        List {
            MyButton(title: "Do this", icon: "star", action: {})
        }
    }
}
