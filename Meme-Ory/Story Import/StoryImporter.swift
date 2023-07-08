//
//  StoryImporter.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 06.12.2020.
//

import Combine
import SwiftUI
import UniformTypeIdentifiers

extension View {
    
    /// Import files via FileImporter.
    /// - Parameter isPresented: Binding Bool to present Import Sheet
    /// - Returns: modified view able to handle import
    func storyImporter<ImportTextView: View>(
        isPresented: Binding<Bool>,
        importTextView: @escaping ([String]) -> ImportTextView
    ) -> some View {
        self.modifier(
            StoryImporter(
                isPresented: isPresented,
                importTextView: importTextView
            )
        )
    }
}

final class StoryImporterModel: ObservableObject {
    
    @Published private(set) var state: State?
    
    private let stateSubject = PassthroughSubject<State?, Never>()
    
    enum State {
        case texts([String])
        case alert(AlertWrapper)
        
        var texts: TextsWrapper? {
            guard case let .texts(texts) = self else { return nil }
            
            return .init(texts: texts)
        }
        
        var alert: AlertWrapper? {
            guard case let .alert(alert) = self else { return nil }
            
            return alert
        }
        
        struct TextsWrapper: Identifiable {
            let texts: [String]
            var id: Int { texts.hashValue }
        }
        
        struct AlertWrapper: Identifiable & Hashable {
            let message: String
            
            var id: Self { self }
        }
    }
    
    init(state: State? = nil) {
        self.state = state
        
        stateSubject
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }
    
    func setState(to wrapper: State.TextsWrapper?) {
        guard let texts = wrapper?.texts else { return }
        stateSubject.send(.texts(texts))
    }
    
    func setState(to alert: State.AlertWrapper?) {
        guard let alert else { return }
        stateSubject.send(.alert(alert))
    }
    
    //  MARK: - Handle Open URL
    
    func handleOpenURL(url: URL) {
        switch url.deeplink {
        case let .file(url: fileURL):
            handleURLResult(.success(fileURL))
            
        default:
            handleError("Can't process your request.\nSorry about that")
        }
    }
    
    //  MARK: - Handle File Importer
    
    func handleURLResult(_ result: Result<URL, Error>) {
        do {
            stateSubject.send(.texts(try result.get().getTexts()))
        } catch {
            handleError(error.localizedDescription)
        }
    }
    
    private func handleError(_ message: String) {
        stateSubject.send(.alert(.init(message: message)))
    }
}

fileprivate struct StoryImporter<ImportTextView: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    
    let importTextView: ([String]) -> ImportTextView
    
    @StateObject var model: StoryImporterModel = .init()
    
    func body(content: Content) -> some View {
        content
            .fileImporter(
                isPresented: $isPresented,
                allowedContentTypes: [UTType.json],
                onCompletion: model.handleURLResult
            )
            .sheet(
                item: .init(
                    get: { model.state?.texts },
                    set: model.setState(to:)
                ),
                content: importTextView
            )
            .alert(
                item: .init(
                    get: { model.state?.alert },
                    set: model.setState(to:)
                ),
                content: alert
            )
    }

    //  MARK: Import File
    
    private func importTextView(
        textsWrapper: StoryImporterModel.State.TextsWrapper
    ) -> some View {
        importTextView(textsWrapper.texts)
    }
    
    //  MARK: - Failed Import Alert
    
    private func alert(
        alert: StoryImporterModel.State.AlertWrapper
    ) -> Alert {
        Alert(
            title: Text("Error"),
            message: Text(alert.message),
            dismissButton: Alert.Button.cancel(Text("Ok"))
        )
    }
}
