//
//  ContentView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 29.11.2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject var filter: Filter
    
    var body: some View {
        RandomStoryListView()
            .environmentObject(RandomStoryListViewModel(context: context))
            .onChange(of: scenePhase, perform: handleScenePhase)
    }
    
    private func handleScenePhase(scenePhase: ScenePhase) {
        if scenePhase == .background {
            #if DEBUG
            print("ContentView: gone to background")
            #endif
            
            context.saveContext()
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
