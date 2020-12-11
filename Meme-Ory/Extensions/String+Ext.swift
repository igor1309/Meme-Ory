//
//  String+Ext.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 11.12.2020.
//

import Foundation

extension String {
    
    // FIXME: get more options for separators
    func splitText() -> [String] {
        let separator = "***"
        let components = self.components(separatedBy: separator)
        
        let cleaned = components
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        return cleaned
    }
    
    /// get first maxLength symbols of the first line
    func oneLinePrefix(_ maxLength: Int) -> String {
        let components = self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
        
        guard let first = components.first else { return "" }
        
        guard first.count > maxLength else { return first }
        
        return String(first.prefix(maxLength)).appending("...")
    }
}
