//
//  Filter.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

extension NSPredicate {
    static var all = NSPredicate(format: "TRUEPREDICATE")
    static var none = NSPredicate(format: "FALSEPREDICATE")
}

struct Filter {
    
    var isActive: Bool {
        isTagFilterActive || isListLimited || favoritesFilter != .all || remindersFilter != .all
    }
    
    
    //  MARK: Favorites

    var favoritesFilter = FavoritesFilterOptions.all
    enum FavoritesFilterOptions: String, CaseIterable {
        case fav, unfav, all

        var rawValue: String {
            switch self {
                case .all:   return "All"
                case .fav:   return "Favorites"
                case .unfav: return "Non Favorites"
            }
        }
    }
    
    
    //  MARK: Reminders

    var remindersFilter = RemindersFilterOptions.all
    enum RemindersFilterOptions: String, CaseIterable {
        case have, notHave, all

        var rawValue: String {
            switch self {
                case .all:     return "All"
                case .have:    return "With"
                case .notHave: return "Without"
            }
        }
    }


    //  MARK: Sort
    
    var itemToSortBy = SortByOptions.text
    enum SortByOptions: String, CaseIterable {
        case timestamp, text
        
        var rawValue: String {
            switch self {
                case .timestamp: return "Date"
                case .text:      return "Text"
            }
        }
    }
    
    /// sort order
    var areInIncreasingOrder: Bool = UserDefaults.standard.bool(forKey: "areInIncreasingOrder") {
        didSet {
            UserDefaults.standard.setValue(areInIncreasingOrder, forKey: "areInIncreasingOrder")
        }
    }
    
    
    //  MARK: Search
    
    var searchString: String = ""
    
    
    //  MARK: List Limit
    
    /// Limiting Stories List (number of stories listed))
    var isListLimited: Bool = UserDefaults.standard.bool(forKey: "isListLimited") {
        didSet {
            UserDefaults.standard.setValue(isListLimited, forKey: "isListLimited")
        }
    }
    var listLimit: Int = max(6, UserDefaults.standard.integer(forKey: "listLimit")) {
        didSet {
            UserDefaults.standard.setValue(listLimit, forKey: "listLimit")
        }
    }
    
    static var listLimitOptions: [Int] = Array(1..<5).map { $0 * 6 }
    
    
    //  MARK: Tags
    
    var tags = Set<Tag>()
    
    var isTagFilterActive: Bool { !tags.isEmpty }
    
    var tagList: String {
        tags.map { $0.name }.sorted().joined(separator: ", ")
    }
    
    
    //  MARK: SortDescriptors
    
    var timestampSortDescriptor: NSSortDescriptor {
        NSSortDescriptor(key: "timestamp_", ascending: areInIncreasingOrder)
    }
        var textSortDescriptor: NSSortDescriptor {
            NSSortDescriptor(key: "text_", ascending: areInIncreasingOrder)
        }
    
    var sortDescriptors: [NSSortDescriptor] {
        switch itemToSortBy {
            case .timestamp: return [timestampSortDescriptor, textSortDescriptor]
            case .text:      return [textSortDescriptor, timestampSortDescriptor]
        }
    }
    
    
    //  MARK: Predicates
    
    private var tagPredicate: NSPredicate {
        isTagFilterActive ?
            NSPredicate(format: "ANY %K IN %@", #keyPath(Story.tags_), Array(tags))
            : NSPredicate.all
    }
    
    private var favoritesPredicate: NSPredicate {
        switch favoritesFilter {
            case .all:
                return NSPredicate.all
            case .fav:
                return NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
            case.unfav:
                return NSPredicate(format: "isFavorite == %@ OR isFavorite = nil", NSNumber(value: false))
        }
    }
    
    private var remindersPredicate: NSPredicate {
        switch remindersFilter {
            case .all:
                return NSPredicate.all
            case .have:
                return NSPredicate(format: "calendarItemIdentifier_ != nil")
            case .notHave:
                return NSPredicate(format: "calendarItemIdentifier_ = nil")
        }
    }
    
    private var searchStringPredicate: NSPredicate {
        searchString.count >= 3 ?
            NSPredicate(format: "text_ CONTAINS[cd] %@", searchString)
            : NSPredicate.all
    }
    
    var predicate: NSPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: [favoritesPredicate, remindersPredicate, tagPredicate, searchStringPredicate])
    }
    
    
    //  MARK: Reset Filter
    
    mutating func reset() {
        tags = Set()
    }
}
