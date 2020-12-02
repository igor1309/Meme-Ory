//
//  ImportTextTesting.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 01.12.2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportTextTesting: View {
    @State private var legends = SampleData.texts
    
    @State private var showingFileImporter = false
    @State private var showingImportTextView = false
    @State private var importFileURL: URL?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(legends, id: \.self) { legend in
                    Text("Row \(legend)")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Stories")
            .navigationBarItems(trailing: navBarMenu())
        }
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [UTType.json], onCompletion: handleFileImporter)
        .sheet(isPresented: $showingImportTextView, onDismiss: { importFileURL = nil }, content: importTextView)
        // observe importFileURL
        //.onChange(of: importFileURL, perform: importFileURLObserver)
    }
    
    // to use with .onChange(of: importFileURL, perform: importFileURLObserver)
    private func importFileURLObserver(url: URL?) {
        if url != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    showingImportTextView = true
                }
            }
        }
    }
    
    private func handleFileImporter(result: (Result<URL, Error>)) {
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
    
    private func navBarMenu() -> some View {
        Menu {
            Button {
                withAnimation {
                    showingFileImporter = true
                }
            } label: {
                Label("Import File", systemImage: "arrow.up.doc")
            }
        } label: {
            Image(systemName: "ellipsis")
        }
    }
    
    @ViewBuilder
    private func importTextView() -> some View {
        if let importFileURL = importFileURL {
            ImportTextView(url: importFileURL)
        } else {
            ErrorSheet(message: "Import error: please try again") { EmptyView() }
        }
    }
}

struct ImportTextTesting_Previews: PreviewProvider {
    static var previews: some View {
        ImportTextTesting()
            .environment(\.colorScheme, .dark)
    }
}
