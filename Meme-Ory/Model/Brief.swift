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

extension Sequence where Element == Brief {
    func convertToStories(in context: NSManagedObjectContext) {
        let date = Date()
        
        for element in self {
            let story = Story(context: context)
            story.text = element.text
            story.timestamp = date
        }
        
        context.saveContext()
    }
}
