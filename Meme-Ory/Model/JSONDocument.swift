//
//  JSONDocument.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 27.11.2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct JSONDocument: FileDocument {
    var data: Data
    
    static var readableContentTypes: [UTType] = [.json]
    
    init(data: Data) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
