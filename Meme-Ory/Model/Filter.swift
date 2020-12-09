//
//  Filter.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

final class Filter: ObservableObject {
    
    var isActive: Bool {
        isTagFilterActive || isListLimited || favoritesFilter != .all || remindersFilter != .all
    }
    
    
    //  MARK: - Favorites
    
    @Published var favoritesFilter = FavoritesFilterOptions.all
    
    enum FavoritesFilterOptions: String, CaseIterable {
        case fav, unfav, all
    }
    
    
    //  MARK: - Reminders
    
    @Published var remindersFilter = RemindersFilterOptions.all
    
    enum RemindersFilterOptions: String, CaseIterable {
        case have, notHave, all
    }
    
    
    //  MARK: - Sort
    
    @Published var itemToSortBy = SortByOptions.timestamp
    
    enum SortByOptions: String, CaseIterable {
        case timestamp, text
    }
    
    /// sort order
    @Published var sortOrder = SortOrder.descending
    
    enum SortOrder: String, CaseIterable {
        case ascending, descending
        
        var areInIncreasingOrder: Bool {
            get { self == .ascending }
            set { self = newValue ? .ascending : .descending}
        }
    }
    
    
    //  MARK: - Search
    @Published var searchString: String = ""
    
    
    //  MARK: - List Limit
    
    /// Limiting Stories List (number of stories listed))
    @Published var isListLimited: Bool = UserDefaults.standard.bool(forKey: "isListLimited") {
        didSet {
            UserDefaults.standard.setValue(isListLimited, forKey: "isListLimited")
        }
    }
    
    @Published var listLimit: Int = max(6, UserDefaults.standard.integer(forKey: "listLimit")) {
        didSet {
            UserDefaults.standard.setValue(listLimit, forKey: "listLimit")
        }
    }
    
    static var listLimitOptions: [Int] = Array(1..<5).map { $0 * 6 }
    
    
    //  MARK: - Tags
    
    @Published var tags = Set<Tag>()
    
    var isTagFilterActive: Bool { !tags.isEmpty }
    
    var tagList: String {
        tags.map { $0.name }.sorted().joined(separator: ", ")
    }
    
    
    //  MARK: - SortDescriptors
    
    private var timestampSortDescriptor: NSSortDescriptor {
        NSSortDescriptor(key: #keyPath(Story.timestamp_), ascending: sortOrder.areInIncreasingOrder)
    }
    
    private var textSortDescriptor: NSSortDescriptor {
        NSSortDescriptor(key: #keyPath(Story.text_), ascending: sortOrder.areInIncreasingOrder)
    }
    
    var sortDescriptors: [NSSortDescriptor] {
        switch itemToSortBy {
            case .timestamp: return [timestampSortDescriptor, textSortDescriptor]
            case .text:      return [textSortDescriptor, timestampSortDescriptor]
        }
    }
    
    
    //  MARK: - Predicates
    
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
                return NSPredicate(format: "%K == %@", #keyPath(Story.isFavorite), NSNumber(value: true))
            case.unfav:
                return NSPredicate(format: "%K == %@ OR %K = nil", #keyPath(Story.isFavorite), NSNumber(value: false), #keyPath(Story.isFavorite))
        }
    }
    
    private var remindersPredicate: NSPredicate {
        switch remindersFilter {
            case .all:
                return NSPredicate.all
            case .have:
                return NSPredicate(format: "%K != nil", #keyPath(Story.calendarItemIdentifier_))
            case .notHave:
                return NSPredicate(format: "%K = nil", #keyPath(Story.calendarItemIdentifier_))
        }
    }
    
    private var searchStringPredicate: NSPredicate {
        searchString.count >= 3 ?
            NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Story.text_), searchString)
            : NSPredicate.all
    }
    
    var predicate: NSPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: [favoritesPredicate, remindersPredicate, tagPredicate, searchStringPredicate])
    }
    
    
    //  MARK: - Reset Filter
    
    func resetTags() {
        tags = Set()
    }
}
