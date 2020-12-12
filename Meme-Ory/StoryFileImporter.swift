//
//  StoryFileImporter.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 06.12.2020.
//

import SwiftUI
import UniformTypeIdentifiers

fileprivate struct StoryFileImporter: ViewModifier {
    
    @Environment(\.managedObjectContext) private var context

    @Binding var isPresented: Bool
    
    @State private var fileURL: FileURL?
    @State private var showingFailedImportAlert = false
    
    struct FileURL: Identifiable {
        let url: URL
        var id: Int { url.hashValue }
    }
    
    func body(content: Content) -> some View {
        content
            .fileImporter(isPresented: $isPresented, allowedContentTypes: [UTType.json], onCompletion: handleFileImporter)
            .sheet(item: $fileURL, content: importTextView)
            .alert(isPresented: $showingFailedImportAlert, content: failedImportAlert)
    }
    
    private func handleFileImporter(_ result: Result<URL, Error>) {
        switch result {
            case .success(let url):
                print("StoryFileImporter: Import success")
                fileURL = FileURL(url: url)
            case .failure(let error):
                print("StoryFileImporter: Import error \(error.localizedDescription)")
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

extension View {
    func storyFileImporter(isPresented: Binding<Bool>) -> some View {
        self.modifier(StoryFileImporter(isPresented: isPresented))
    }
}
