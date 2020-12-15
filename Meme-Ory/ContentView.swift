//
//  ContentView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 29.11.2020.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject private var model: MainViewModel
    
    var body: some View {
        NavigationView {
            MainView(fetchRequest: model.request)
        }
        .onChange(of: scenePhase, perform: handleScenePhase)
        .onOpenURL(perform: model.handleURL)
        .storyImporter(isPresented: $model.showingFileImporter)
        .fileExporter(isPresented: $model.showingFileExporter, document: model.document, contentType: .json, onCompletion: model.handleFileExporter)
    }
    
    
    //  MARK: - Scene Change Handling
    
    private func handleScenePhase(scenePhase: ScenePhase) {
        if scenePhase == .background {
            #if DEBUG
            print("ContentView: gone to background")
            #endif
            
            model.deleteTemporaryFile()
            context.saveContext()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    @State static var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(MainViewModel(context: context, viewMode: .list))
            
            ContentView()
                .environmentObject(MainViewModel(context: context))
        }
        .environment(\.managedObjectContext, context)
        .environmentObject(EventStore())
        .environment(\.colorScheme, .dark)
        .previewLayout(.fixed(width: 350, height: 500))
    }
}
