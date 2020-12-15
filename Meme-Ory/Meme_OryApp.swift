//
//  Meme_OryApp.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

@main
struct Meme_OryApp: App {
    
    let persistenceController: PersistenceController
    
    @StateObject private var eventStore = EventStore()
    @StateObject private var listModel: MainViewModel
    
    init() {
        persistenceController = PersistenceController.shared
        let context = persistenceController.container.viewContext
        _listModel = StateObject(wrappedValue: MainViewModel(context: context))
    }
    
    var body: some Scene {
        WindowGroup {
            //StoryImportTester()
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(listModel)
                .environmentObject(eventStore)
        }
    }
}
