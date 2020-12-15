//
//  Meme_OryApp.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

@main
struct Meme_OryApp: App {
    
    let storageProvider: StorageProvider
    
    @StateObject private var eventStore = EventStore()
    @StateObject private var listModel: MainViewModel
    
    init() {
        storageProvider = StorageProvider.shared
        let context = storageProvider.container.viewContext
        _listModel = StateObject(wrappedValue: MainViewModel(context: context))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, storageProvider.container.viewContext)
                .environmentObject(listModel)
                .environmentObject(eventStore)
        }
    }
}
