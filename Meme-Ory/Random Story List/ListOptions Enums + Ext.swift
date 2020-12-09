//
//  ListOptions Enums + Ext.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 09.12.2020.
//

import SwiftUI


//  MARK: - Enum Extensions: Labelable

extension ListOptions.FavoritesFilterOptions: Labelable {
    var rawValue: String {
        switch self {
            case .all:   return "Favorites or not"
            case .fav:   return "Favorites"
            case .unfav: return "Non Favorites"
        }
    }
    
    var icon: String {
        switch self {
            case .all:   return "star.leadinghalf.fill"
            case .fav:   return "star.circle"
            case .unfav: return "star.slash"
        }
    }
}

extension ListOptions.RemindersFilterOptions: Labelable {
    var rawValue: String {
        switch self {
            case .all:     return "With or without"
            case .have:    return "With reminder"
            case .notHave: return "No reminder"
        }
    }
    
    var icon: String {
        switch self {
            case .all:   return "bell.slash.circle.fill"
            case .have:   return "bell.circle"
            case .notHave: return "bell.slash"
        }
    }
}

extension ListOptions.SortByOptions: Labelable {
    var rawValue: String {
        switch self {
            case .timestamp: return "Date"
            case .text:      return "Text"
        }
    }
    
    var icon: String {
        switch self {
            case .timestamp: return "calendar"
            case .text:      return "text.cursor"
        }
    }
}

extension ListOptions.SortOrder: Labelable {
    var rawValue: String {
        switch self {
            case .ascending:  return "Ascending"
            case .descending: return "Descending"
        }
    }
    
    var icon: String {
        switch self {
            case .ascending:  return "textformat.size"
            case .descending: return "textformat"
        }
    }
}


//  MARK:- Enum Extensions: Identifiable

extension ListOptions.FavoritesFilterOptions: Identifiable {
    var id: Int { hashValue}
}
extension ListOptions.RemindersFilterOptions: Identifiable {
    var id: Int { hashValue}
}
extension ListOptions.SortByOptions: Identifiable {
    var id: Int { hashValue}
}
extension ListOptions.SortOrder: Identifiable {
    var id: Int { hashValue}
}

