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
    
    @State private var fileURL: FileURL?
    @State private var showingFailedImportAlert = false
    
    struct FileURL: Identifiable {
        let url: URL
        var id: Int { url.hashValue }
    }
    
    var body: some View {
        
        RandomStoryListView(context: context)
            .onChange(of: scenePhase, perform: handleScenePhase)
            .onOpenURL(perform: handleOpenURL)
            .sheet(item: $fileURL, content: importTextView)
            .alert(isPresented: $showingFailedImportAlert, content: failedImportAlert)
    }
    
    private func handleScenePhase(scenePhase: ScenePhase) {
        if scenePhase == .background {
            print("ContentView: gone to background")
            context.saveContext()
        }
    }
    
    
    //  MARK: Handle Open URL
    
    private func handleOpenURL(url: URL) {
        guard let deeplink = url.deeplink else {
            showingFailedImportAlert = true
            return
        }
        
        switch deeplink {
            case .home:
                //  MARK: - FINISH THIS: ANY FEEDBACK TO USER?
                /// do nothing we are here
                return
            case .story(_):
                // FIXME: no more StoryView
                // do nothing here: this case is handled by StoryView
                return
            case let .file(url):
                withAnimation {
                    fileURL = FileURL(url: url)
                    print("ContentView: handleOpenURL: importing file \(url)")
                }
        }
    }
    
    //  MARK: Import File
    
    private func importTextView(fileURL: FileURL) -> some View {
        ImportTextView(url: fileURL.url)
            .environment(\.managedObjectContext, context)
    }
    
    private func failedImportAlert() -> Alert {
        Alert(title: Text("Error"), message: Text("Can't process yuor request.\nSorry about that"), dismissButton: Alert.Button.cancel(Text("Ok")))
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
