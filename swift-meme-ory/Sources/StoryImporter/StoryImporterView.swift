//
//  StoryImporterView.swift
//  
//
//  Created by Igor Malyarov on 08.07.2023.
//

import SwiftUI
import UniformTypeIdentifiers

struct StoryImporterView<ImportTextView: View>: ViewModifier {
    
    @Binding private var isPresented: Bool
    
    @StateObject private var model: StoryImporterModel
    
    private let importTextView: ([String]) -> ImportTextView
    
    init(
        isPresented: Binding<Bool>,
        getTexts: @escaping (URL) throws -> [String],
        importTextView: @escaping ([String]) -> ImportTextView
    ) {
        self._isPresented = isPresented
        self._model = .init(wrappedValue: .init(getTexts: getTexts))
        self.importTextView = importTextView
    }
    
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
