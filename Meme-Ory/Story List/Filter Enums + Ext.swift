//
//  LabelProvider.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 09.12.2020.
//

import SwiftUI


//  MARK: LabelProvider

protocol LabelProvider: RawRepresentable where Self.RawValue == String {
    var icon: String { get }
    
    associatedtype V: View
    func label(prefix: String) -> V
}

extension LabelProvider {
    func label(prefix: String = "") -> some View {
        let title = prefix.isEmpty ? rawValue : "\(prefix)\(rawValue)"
        return Label(title, systemImage: icon)
    }
}


//  MARK: - Enum Extensions: LabelProvider

extension Filter.FavoritesFilterOptions: LabelProvider {
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

extension Filter.RemindersFilterOptions: LabelProvider {
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

extension Filter.SortByOptions: LabelProvider {
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

extension Filter.SortOrder: LabelProvider {
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

extension Filter.FavoritesFilterOptions: Identifiable {
    var id: Int { hashValue}
}
extension Filter.RemindersFilterOptions: Identifiable {
    var id: Int { hashValue}
}
extension Filter.SortByOptions: Identifiable {
    var id: Int { hashValue}
}
extension Filter.SortOrder: Identifiable {
    var id: Int { hashValue}
}
