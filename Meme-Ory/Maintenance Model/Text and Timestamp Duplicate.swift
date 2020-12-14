//
//  Text and Timestamp Duplicate.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import Foundation

struct TextDuplicate: Equatable, Identifiable {
    let id = UUID()
    
    let text: String
    let count: Int
}

struct TimestampDuplicate: Equatable, Identifiable {
    let id = UUID()
    
    let date: Date
    let count: Int
}

