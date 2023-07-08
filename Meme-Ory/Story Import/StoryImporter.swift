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

final class StoryImporterModel: ObservableObject {
    
    @Published var showingFailedImportAlert = false
    @Published var textsWrapper: TextsWrapper?
    
    struct TextsWrapper: Identifiable {
        let texts: [String]
        var id: Int { texts.hashValue }
    }
    
    //  MARK: - Handle Open URL
    
    func handleOpenURL(url: URL) {
        guard let deeplink = url.deeplink,
              case .file(let fileURL) = deeplink
        else {
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
    
    func handleFileImporter(_ result: Result<URL, Error>) {
        do {
            textsWrapper = .init(texts: try result.get().getTexts())
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        print("StoryImporter: Import error \(error.localizedDescription)")
    }
}

fileprivate struct StoryImporter: ViewModifier {
    
    @Environment(\.managedObjectContext) private var context
    
    @Binding var isPresented: Bool
    
    @StateObject var model: StoryImporterModel = .init()
    
    func body(content: Content) -> some View {
        content
            .fileImporter(
                isPresented: $isPresented,
                allowedContentTypes: [UTType.json],
                onCompletion: model.handleFileImporter
            )
            .sheet(
                item: $model.textsWrapper,
                content: importTextView
            )
            .alert(
                isPresented: $model.showingFailedImportAlert,
                content: failedImportAlert
            )
    }

    //  MARK: Import File
    
    private func importTextView(
        textsWrapper: StoryImporterModel.TextsWrapper
    ) -> some View {
        ImportTextView(texts: textsWrapper.texts)
            .environment(\.managedObjectContext, context)
    }
    
    //  MARK: - Failed Import Alert
    
    private func failedImportAlert() -> Alert {
        Alert(
            title: Text("Error"),
            message: Text("Can't process your request.\nSorry about that"),
            dismissButton: Alert.Button.cancel(Text("Ok"))
        )
    }
}
