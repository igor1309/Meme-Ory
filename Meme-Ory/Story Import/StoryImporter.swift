//
//  StoryImporter.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 06.12.2020.
//

import SwiftUI
import UniformTypeIdentifiers

fileprivate struct StoryImporter: ViewModifier {
    
    @Environment(\.managedObjectContext) private var context
    
    @Binding var isPresented: Bool
    
    @State private var showingFailedImportAlert = false
    @State private var textsStruct: TextsStruct?
    
    struct TextsStruct: Identifiable {
        let texts: [String]
        var id: Int { texts.hashValue }
    }
    
    func body(content: Content) -> some View {
        content
            .fileImporter(isPresented: $isPresented, allowedContentTypes: [UTType.json], onCompletion: handleFileImporter)
            .sheet(item: $textsStruct, content: importTextView)
            .alert(isPresented: $showingFailedImportAlert, content: failedImportAlert)
            //.onOpenURL(perform: handleOpenURL)
    }
    
    
    //  MARK: - Handle Open URL
    
    private func handleOpenURL(url: URL) {
        guard let deeplink = url.deeplink,
              case .file(let fileURL) = deeplink else {
            showingFailedImportAlert = true
            return
        }
        
        withAnimation {
            let texts = fileURL.getTexts()
            
            #if DEBUG
            print("StoryImporter: handleOpenURL: importing file \(url)")
            print("StoryImporter: handleFileImporter: \((texts.first ?? "no texts").prefix(30))...")
            #endif
            
            textsStruct = TextsStruct(texts: texts)
        }
    }
    
    
    //  MARK: - Handle File Importer
    
    private func handleFileImporter(_ result: Result<URL, Error>) {
        switch result {
            case .success(let url):
                #if DEBUG
                print("StoryImporter: Import success")
                #endif
                
                let texts = url.getTexts()
                
                #if DEBUG
                print("StoryImporter: handleFileImporter: \((texts.first ?? "no texts").prefix(30))...")
                #endif
                
                textsStruct = TextsStruct(texts: texts)
                
            case .failure(let error):
                print("StoryImporter: Import error \(error.localizedDescription)")
        }
    }
    
    //  MARK: Import File
    
    private func importTextView(textsStruct: TextsStruct) -> some View {
        ImportTextView(texts: textsStruct.texts)
            .environment(\.managedObjectContext, context)
    }
    
    
    //  MARK: - Failed Import Alert
    
    private func failedImportAlert() -> Alert {
        Alert(title: Text("Error"), message: Text("Can't process your request.\nSorry about that"), dismissButton: Alert.Button.cancel(Text("Ok")))
    }
    
}

extension View {
    
    /// import files via fileImporter and onOpenURL
    /// - Parameter isPresented: Binnding Bool to present Import Sheet
    /// - Returns: modified view able to handli import
    func storyImporter(isPresented: Binding<Bool>) -> some View {
        self.modifier(StoryImporter(isPresented: isPresented))
    }
}
