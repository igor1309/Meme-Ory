//
//  String+trimmed.swift
//  
//
//  Created by Igor Malyarov on 12.06.2023.
//

extension String {
    
    /// Remove illegalCharacters, trim whitespaces and newlines from elements, drop empty elements
    func trimmed() -> String {
        self
            .components(separatedBy: .illegalCharacters)
            .joined(separator: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
