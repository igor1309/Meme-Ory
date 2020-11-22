//
//  Meme_OryApp.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

@main
struct Meme_OryApp: App {
    
    let persistenceController = PersistenceController.shared
    
    @State private var filter = Filter()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                StoryListView(filter: $filter)
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
