//
//  SingleStoryToolbar.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 12.06.2023.
//

import SwiftUI

struct SingleStoryToolbar<FavoriteIcon: View, ReminderIcon: View>: View {
    
    let switchViewMode: () -> Void
    let favoriteIcon: () -> FavoriteIcon
    let reminderIcon: () -> ReminderIcon
    
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
}

struct SingleStoryToolbar_Previews: PreviewProvider {
    static var previews: some View {
        SingleStoryToolbar(
            switchViewMode: {},
            favoriteIcon: { Image(systemName: "star")},
            reminderIcon: { Image(systemName: "bell")}
        )
    }
}
