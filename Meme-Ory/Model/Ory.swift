//
//  Ory.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 07.12.2020.
//

import SwiftUI
import CoreHaptics

// Global Namespace
//
enum Ory {
    
    static let storyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    
    //  MARK: - Haptics
    
    private static let hapticsAvailable: Bool = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    
    static func feedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        if hapticsAvailable {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
    
    static func feedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        if hapticsAvailable {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(type)
        }
    }
    
    
    //  MARK: - with Animation
    
    static func withHapticsAndAnimation(style: UIImpactFeedbackGenerator.FeedbackStyle = .light, action: @escaping () -> Void) {
        feedback(style: style)
        
        withAnimation {
            action()
        }
    }

    static func withHapticsAndAnimation(type: UINotificationFeedbackGenerator.FeedbackType, action: @escaping () -> Void) {
        feedback(type: type)
        
        withAnimation {
            action()
        }
    }

}
