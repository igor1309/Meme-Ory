//
//  Sequence+trimmed.swift
//  
//
//  Created by Igor Malyarov on 12.06.2023.
//

extension Sequence where Element == String {
    
    /// Remove illegalCharacters, trim whitespaces and newlines from elements, drop empty elements
    func trimmed() -> [Element] {
        self
            .map { $0.trimmed() }
            .filter { !$0.isEmpty }
    }
}
