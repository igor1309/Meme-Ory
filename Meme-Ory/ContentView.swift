//
//  ContentView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 29.11.2020.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    
    let persistenceController = PersistenceController.shared
    
    @StateObject private var eventStore = EventStore()
    @StateObject private var filter = Filter()
    
    var body: some View {
        NavigationView {
            StoryListView(filter: filter)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(eventStore)
                .environmentObject(filter)

        }
        .onChange(of: scenePhase, perform: handleScenePhase)
    }
    
    private func handleScenePhase(scenePhase: ScenePhase) {
        if scenePhase == .background {
            persistenceController.container.viewContext.saveContext()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .environmentObject(EventStore())
            .environmentObject(Filter())
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 350, height: 800))
        
    }
}
