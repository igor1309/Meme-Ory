//
//  Brief.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 27.11.2020.
//

import Foundation
import CoreData

struct Brief: Identifiable, Hashable {
    let id = UUID()
    
    let text: String
    var check: Bool = false
}

extension Brief: Codable {
    enum CodingKeys: CodingKey { case text }
}

extension Brief: Comparable {
    static func < (lhs: Brief, rhs: Brief) -> Bool {
        lhs.text < rhs.text
    }
}

extension Brief {
    static var example: Brief {
        Brief.examples.randomElement()!
    }
    
    static var examples: [Brief] {
        SampleData.texts.map { Brief(text: $0, check: Bool.random()) }
    }
}

extension Sequence where Element == Brief {
    func convertToStories(in context: NSManagedObjectContext) {
        for brief in self {
            let story = Story(context: context)
            story.text = brief.text
        }
        
        context.saveContext()
    }
}

extension URL {
    func getBriefs() -> [Brief] {
        guard let data = try? Data(contentsOf: self) else {
            print("Failed to load file at \(self) from bundle.")
            return []
        }
        
        let decoder = JSONDecoder()
        
        guard let briefs = try? decoder.decode([Brief].self, from: data) else {
            print("Failed to decode file at \(self).")
            return []
        }
        
        /// remove duplicates from import
        /// this doesn't check for duplicates in store
        return Array(Set(briefs)).sorted()
    }
}
