//
//  Meme_OryApp.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

@main
struct Meme_OryApp: App {
    
    @StateObject var storageProvider: StorageProvider
    
    init() {
        let storageProvider = StorageProvider()
        _storageProvider = StateObject(wrappedValue: storageProvider)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(context: storageProvider.container.viewContext)
        }
    }
}
