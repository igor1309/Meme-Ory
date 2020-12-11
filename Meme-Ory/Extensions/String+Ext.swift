//
//  String+Ext.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 11.12.2020.
//

import Foundation

extension String {
    func oneLinePrefix(_ maxLength: Int) -> String {
        let components = self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "\n")
        
        guard let first = components.first else { return "" }
        
        guard first.count > maxLength else { return first }
        
        return String(first.prefix(maxLength)).appending("...")
    }
}
