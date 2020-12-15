//
//  String+Ext.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 11.12.2020.
//

import SwiftUI

extension String {
    
    public func trimmed() -> String {
        self
            .components(separatedBy: CharacterSet.illegalCharacters)
            .joined(separator: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
    // FIXME: get more options for separators
    func splitText() -> [String] {
        let separator = "***"
        let components = self.components(separatedBy: separator)
        
        return components.trimmed()
    }
    
    /// get first maxLength symbols of the first line
    func oneLinePrefix(_ maxLength: Int) -> String {
        let components = self
            .components(separatedBy: "\n")
            .trimmed()
        
        guard let first = components.first else { return "" }
        
        guard first.count > maxLength else { return first }
        
        return String(first.prefix(maxLength)).appending("...")
    }
    
    
    //  MARK: - Story Text View
    
    @ViewBuilder
    func storyText(maxTextLength: Int) -> some View {
        if count > maxTextLength {
            Text("Story too long, showing first \(maxTextLength) characters\n\n").foregroundColor(Color(UIColor.systemRed)).font(.footnote)
                + Text(prefix(maxTextLength))
        } else {
            Text(self)
        }
    }
    
    

}
