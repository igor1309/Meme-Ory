//
//  Filter.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import Foundation

struct Filter {
    var string = ""
    var tags = Set<Tag>()

    var isActive: Bool { !tags.isEmpty }
    
    var tagList: String {
        tags.map { $0.name }.joined(separator: ", ")
    }
}
