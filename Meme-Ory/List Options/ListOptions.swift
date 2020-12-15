//
//  ListOptions.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 09.12.2020.
//

import CoreData

struct ListOptions {
    
    init(limit: Int?) {
        if let limit = limit {
            self.listLimit = limit
            self.isListLimited = true
        } else {
            self.isListLimited = false
        }
    }
    
    mutating func reset() {
        self.isTagFilterActive = false
        self.isListLimited = false
        self.remindersFilter = .all
        self.favoritesFilter = .all
    }
    
    var isActive: Bool {
        isTagFilterActive || isListLimited || remindersFilter != .all || favoritesFilter != .all
    }
    
    
    //  MARK: - Favorites
    
    var favoritesFilter = FavoritesFilterOptions.all
    
    enum FavoritesFilterOptions: String, CaseIterable {
        case fav, unfav, all
    }
    
    
    //  MARK: - Reminders
    
    var remindersFilter = RemindersFilterOptions.all
    
    enum RemindersFilterOptions: String, CaseIterable {
        case have, notHave, all
    }
    
    
    //  MARK: - Sort
    
    var itemToSortBy = SortByOptions.timestamp
    
    enum SortByOptions: String, CaseIterable {
        case timestamp, text
    }
    
    /// sort order
    var sortOrder = SortOrder.descending
    
    enum SortOrder: String, CaseIterable {
        case ascending, descending
        
        var areInIncreasingOrder: Bool {
            get { self == .ascending }
            set { self = newValue ? .ascending : .descending}
        }
    }
    
    
    //  MARK: - Search
    var searchString: String = ""
    
    
    //  MARK: - List Limit
    
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
    
    
    //  MARK: - Tags
    
    var tags = Set<Tag>()
    
    var isTagFilterActive: Bool {
        get { !tags.isEmpty }
        set { resetTags() }
    }
    
    var tagList: String {
        tags.map { $0.name }.sorted().joined(separator: ", ")
    }
    
    
    //  MARK: - Fetch Request
    
    var fetchRequest: NSFetchRequest<Story> {
        
        //  MARK: SortDescriptors
        
        let timestampSortDescriptor = NSSortDescriptor(key: #keyPath(Story.timestamp_), ascending: sortOrder.areInIncreasingOrder)
        
        let textSortDescriptor = NSSortDescriptor(key: #keyPath(Story.text_), ascending: sortOrder.areInIncreasingOrder)
        
        var sortDescriptors: [NSSortDescriptor] {
            switch itemToSortBy {
                case .timestamp: return [timestampSortDescriptor, textSortDescriptor]
                case .text:      return [textSortDescriptor, timestampSortDescriptor]
            }
        }
        
        
        //  MARK: Predicates
        
        var tagPredicate: NSPredicate {
            isTagFilterActive
                ? NSPredicate(format: "ANY %K IN %@", #keyPath(Story.tags_), Array(tags))
                : NSPredicate.all
        }
        
        var favoritesPredicate: NSPredicate {
            switch favoritesFilter {
                case .all:
                    return NSPredicate.all
                case .fav:
                    return NSPredicate(format: "%K == %@", #keyPath(Story.isFavorite), NSNumber(value: true))
                case.unfav:
                    return NSPredicate(format: "%K == %@ OR %K = nil", #keyPath(Story.isFavorite), NSNumber(value: false), #keyPath(Story.isFavorite))
            }
        }
        
        var remindersPredicate: NSPredicate {
            switch remindersFilter {
                case .all:
                    return NSPredicate.all
                case .have:
                    return NSPredicate(format: "%K != nil", #keyPath(Story.calendarItemIdentifier_))
                case .notHave:
                    return NSPredicate(format: "%K = nil", #keyPath(Story.calendarItemIdentifier_))
            }
        }
        
        var searchStringPredicate: NSPredicate {
            searchString.count >= 3
                ? NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(Story.text_), searchString)
                : NSPredicate.all
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [favoritesPredicate, remindersPredicate, tagPredicate, searchStringPredicate])

        
        //  MARK: Fetch Request
        
        let request = Story.fetchRequest(predicate, sortDescriptors: sortDescriptors)
        if isListLimited {
            request.fetchLimit = listLimit
        }
        
        return request
    }

    
    //  MARK: - Reset Tags
    
    mutating func resetTags() {
        tags = Set()
    }
}
