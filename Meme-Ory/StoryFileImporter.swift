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
    
    @State private var importFileURL: URL?
    @State private var showingImportTextView = false
    @State private var showingFailedImportAlert = false

    func body(content: Content) -> some View {
        content
            .fileImporter(isPresented: $isPresented, allowedContentTypes: [UTType.json], onCompletion: handleFileImporter)
            .sheet(isPresented: $showingImportTextView, onDismiss: { importFileURL = nil }, content: importTextView)
            .alert(isPresented: $showingFailedImportAlert, content: failedImportAlert)
    }
    
    private func handleFileImporter(_ result: Result<URL, Error>) {
        switch result {
            case .success(let url):
                print("Import success")
                importFileURL = url
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        showingImportTextView = true
                    }
                }
            case .failure(let error):
                print("Import error \(error.localizedDescription)")
        }
    }
    
    //  MARK: Import File
    
    private func importTextView() -> some View {
        ImportTextView(url: importFileURL)
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
