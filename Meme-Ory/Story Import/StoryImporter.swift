//
//  StoryImporter.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 06.12.2020.
//

import SwiftUI
import UniformTypeIdentifiers

extension View {
    
    /// Import files via FileImporter.
    /// - Parameter isPresented: Binding Bool to present Import Sheet
    /// - Returns: modified view able to handle import
    func storyImporter(isPresented: Binding<Bool>) -> some View {
        self.modifier(StoryImporter(isPresented: isPresented))
    }
}

fileprivate struct StoryImporter: ViewModifier {
    
    @Environment(\.managedObjectContext) private var context
    
    @Binding var isPresented: Bool
    
    @State private var showingFailedImportAlert = false
    @State private var textsWrapper: TextsWrapper?
    
    private struct TextsWrapper: Identifiable {
        let texts: [String]
        var id: Int { texts.hashValue }
    }
    
    func body(content: Content) -> some View {
        content
            .fileImporter(isPresented: $isPresented, allowedContentTypes: [UTType.json], onCompletion: handleFileImporter)
            .sheet(item: $textsWrapper, content: importTextView)
            .alert(isPresented: $showingFailedImportAlert, content: failedImportAlert)
    }
    
    //  MARK: - Handle Open URL
    
    private func handleOpenURL(url: URL) {
        guard let deeplink = url.deeplink,
              case .file(let fileURL) = deeplink else {
            showingFailedImportAlert = true
            return
        }
        
        withAnimation {
            let texts = (try? fileURL.getTexts()) ?? []
            
            #if DEBUG
            print("StoryImporter: handleOpenURL: importing file \(url)")
            print("StoryImporter: handleFileImporter: \((texts.first ?? "no texts").prefix(30))...")
            #endif
            
            textsWrapper = TextsWrapper(texts: texts)
        }
    }
    
    //  MARK: - Handle File Importer
    
    private func handleFileImporter(_ result: Result<URL, Error>) {
        switch result {
            case .success(let url):
                #if DEBUG
                print("StoryImporter: Import success")
                #endif
                
                let texts = (try? url.getTexts()) ?? []
                
                #if DEBUG
                print("StoryImporter: handleFileImporter: \((texts.first ?? "no texts").prefix(30))...")
                #endif
                
                textsWrapper = TextsWrapper(texts: texts)
                
            case .failure(let error):
                print("StoryImporter: Import error \(error.localizedDescription)")
        }
    }
    
    //  MARK: Import File
    
    private func importTextView(textsWrapper: TextsWrapper) -> some View {
        ImportTextView(texts: textsWrapper.texts)
            .environment(\.managedObjectContext, context)
    }
    
    //  MARK: - Failed Import Alert
    
    private func failedImportAlert() -> Alert {
        Alert(title: Text("Error"), message: Text("Can't process your request.\nSorry about that"), dismissButton: Alert.Button.cancel(Text("Ok")))
    }
}
