//
//  View+storyImporter.swift
//  
//
//  Created by Igor Malyarov on 08.07.2023.
//

import SwiftUI

public extension View {
    
    /// Import files via FileImporter.
    /// - Parameter isPresented: Binding Bool to present Import Sheet
    /// - Returns: modified view able to handle import
    func storyImporter<ImportTextView: View>(
        isPresented: Binding<Bool>,
        getTexts: @escaping (URL) throws -> [String],
        importTextView: @escaping ([String]) -> ImportTextView
    ) -> some View {
        self.modifier(
            StoryImporterView(
                isPresented: isPresented,
                getTexts: getTexts,
                importTextView: importTextView
            )
        )
    }
}

struct StoryImporterView_Previews: PreviewProvider {
    static var previews: some View {
        StoryImporterDemo()
    }
    
    private struct StoryImporterDemo: View {
        @State private var isPresented = false
        
        var body: some View {
            Button("Import") {
                isPresented = true
            }
            .storyImporter(
                isPresented: $isPresented,
                getTexts: { _ in [] },
                importTextView: { _ in Text("TBD") }
            )
        }
    }
}
