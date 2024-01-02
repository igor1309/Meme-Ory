//
//  Meme_OryApp.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

@main
struct Meme_OryApp: App {
    
    @StateObject private var storageProvider = StorageProvider()
    @State private var isShowingLaunchScreen = true
    
    var body: some Scene {
        WindowGroup {
            
            ZStack {
                ContentView(context: storageProvider.container.viewContext)

                LaunchScreenView()
                    .opacity(isShowingLaunchScreen ? 1 : 0)
                    .animation(.easeInOut(duration: 1), value: isShowingLaunchScreen)
            }
            .onAppear(perform: hideLaunchScreen)
        }
    }
    
    private func hideLaunchScreen() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            isShowingLaunchScreen = false
        }
    }
}
