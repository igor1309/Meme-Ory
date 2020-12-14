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

