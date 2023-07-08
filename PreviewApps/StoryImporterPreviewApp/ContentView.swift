//
//  ContentView.swift
//  StoryImporterPreviewApp
//
//  Created by Igor Malyarov on 08.07.2023.
//

import StoryImporter
import SwiftUI

struct ContentView: View {
    
    @State private var isPresented = false
    
    var body: some View {
        Button("Import") {
            isPresented = true
        }
        .storyImporter(
            isPresented: $isPresented,
            getTexts: { _ in [] },
            importTextView: { _ in Text("Import results here") }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
