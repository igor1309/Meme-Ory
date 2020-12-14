//
//  Sequence+Ext.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import CoreData

extension Sequence where Element == String {
    /// Remove whitespaces and newlines from elements, drop empty elements
    public func trimmed() -> [Element] {
        self
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

extension Sequence where Element == Brief {
    func convertToStories(in context: NSManagedObjectContext) {
        let date = Date()
        
        for element in self {
            let story = Story(context: context)
            story.text = element.text.trimmingCharacters(in: .whitespacesAndNewlines)
            story.timestamp = date
        }
        
        context.saveContext()
    }
}
