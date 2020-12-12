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
    
    @StateObject private var eventStore = EventStore()
    @StateObject private var filter = Filter()
    
    var body: some Scene {
        WindowGroup {
            //StoryImportTester()
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(eventStore)
                .environmentObject(filter)
        }
    }
}
