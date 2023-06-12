//
//  SingleStoryToolbar.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 12.06.2023.
//

import SwiftUI

struct SingleStoryToolbar: View {
    
    let switchViewMode: () -> Void
    let isFavorite: Bool
    let hasReminder: Bool
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Button(action: switchViewMode) {
                
                Label("Switch to List", systemImage: "list.bullet")
            }
            
            Spacer()
            
            Group {
                favoriteIcon()
                reminderIcon()
            }
            .imageScale(.small)
            // .cardModifier(padding: 9, cornerRadius: 9, background: cardBackground)
        }
    }
    
    //  MARK: - Icons
    
    @ViewBuilder
    private func favoriteIcon() -> some View {
        Image(systemName: isFavorite ? "star.fill" : "star")
            .foregroundColor(isFavorite ? Color(UIColor.systemOrange) : .secondary)
    }
    
    @ViewBuilder
    private func reminderIcon() -> some View {
        Image(systemName: hasReminder ? "bell.fill" : "bell.slash")
            .foregroundColor(hasReminder ? Color(UIColor.systemTeal) : .secondary)
    }
}

struct SingleStoryToolbar_Previews: PreviewProvider {
    
    static var previews: some View {
        
        VStack {
            
            singleStoryToolbar(true, true)
            singleStoryToolbar(true, false)
            singleStoryToolbar(false, true)
            singleStoryToolbar(false, false)
        }
    }
    
    private static func singleStoryToolbar(
        switchViewMode: @escaping () -> Void = {},
        _ isFavorite: Bool,
        _ hasReminder: Bool
    ) -> some View {
        
        SingleStoryToolbar(
            switchViewMode: switchViewMode,
            isFavorite: isFavorite,
            hasReminder: hasReminder
        )
    }
}
