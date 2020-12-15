//
//  ContentView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 29.11.2020.
//

import SwiftUI
import CoreData
import WidgetKit

struct ContentView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var eventStore: EventStore
    @StateObject private var model: MainViewModel
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        let eventStore = EventStore()
        _eventStore = StateObject(wrappedValue: eventStore)
        
        let model = MainViewModel(context: context)
        _model = StateObject(wrappedValue: model)
    }
    
    
    var body: some View {
        NavigationView {
            MainView(fetchRequest: model.request)
        }
        .onChange(of: scenePhase, perform: handleScenePhase)
        .onOpenURL(perform: model.handleURL)
        .storyImporter(isPresented: $model.showingFileImporter)
        .fileExporter(isPresented: $model.showingFileExporter, document: model.document, contentType: .json, onCompletion: model.handleFileExporter)
        .environment(\.managedObjectContext, context)
        .environmentObject(eventStore)
        .environmentObject(model)
    }
    
    
    //  MARK: - Scene Change Handling
    
    private func handleScenePhase(scenePhase: ScenePhase) {
        if scenePhase == .background || scenePhase == .inactive {
            #if DEBUG
            print("ContentView: gone to background or inactive state")
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
            ContentView(context: context)
                .environmentObject(MainViewModel(context: context, viewMode: .list))
            
            ContentView(context: context)
                .environmentObject(MainViewModel(context: context))
        }
        .environment(\.managedObjectContext, context)
        .environmentObject(EventStore())
        .environment(\.colorScheme, .dark)
        .previewLayout(.fixed(width: 350, height: 500))
    }
}
