//
//  String+firstLinePrefix.swift
//  
//
//  Created by Igor Malyarov on 12.06.2023.
//

extension String {
    
    func firstLinePrefix(
        maxedWith maxLength: Int?
    ) -> String {
        let components = self
            .components(separatedBy: "\n")
            .trimmed()
        
        guard let maxLength else { return self }
        
        guard let first = components.first else { return "" }
        
        guard first.count > maxLength else { return first }
        
        return String(first.prefix(maxLength)).appending("...")
    }
}
