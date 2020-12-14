//
//  ListKind.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import CoreData

enum ListKind {
    case withTimestamp, withoutTimestamp, textDuplicates
    
    var listHeader: String {
        switch self {
            case .withTimestamp:    return "Sorted by descending timestamps"
            case .withoutTimestamp: return "No Timestamp Stories"
            case .textDuplicates:   return "Duplicates with Selected Text"
        }
    }
    
    func predicate(selectedTimestampDate: Date?, selectedText: String?) -> NSPredicate {
        switch self {
            case .withTimestamp:    return timestampPredicate(selectedTimestampDate)
            case .withoutTimestamp: return noTimestampPredicate
            case .textDuplicates:   return predicateForSelectedText(selectedText)
        }
    }
    
    private func predicateForSelectedText(_ selectedText: String?) -> NSPredicate {
        if let selectedText = selectedText {
            return NSPredicate(format: "%K == %@", #keyPath(Story.text_), selectedText)
        } else {
            return NSPredicate.none
        }
    }
    
    private func timestampPredicate(_ selectedTimestampDate: Date?) -> NSPredicate {
        if let timestampDate = selectedTimestampDate {
            return NSPredicate(format: "%K == %@", #keyPath(Story.timestamp_), timestampDate as NSDate)
        } else {
            return NSPredicate.all
        }
    }
    
    private var noTimestampPredicate: NSPredicate {
        NSPredicate(format: "%K == null", #keyPath(Story.timestamp_))
    }
}

