//
//  MainViewModel Enums + Ext.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 13.12.2020.
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

extension MainViewModel.ViewMode: LabelProvider {
    var rawValue: String {
        switch self {
            case .single: return "Single Story"
            case .list:   return "List"
        }
    }
    
    var icon: String {
        switch self {
            case .single: return "doc.plaintext"
            case .list:   return "list.bullet"
        }
    }
}


//  MARK: - Enum Extensions: Identifiable

extension MainViewModel.SheetID: Identifiable {
    
    var id: Int {
        switch self {
            case .new:            return "new".hashValue
            case .edit: return "edit".hashValue
            case .tags:           return "tags".hashValue
            case .maintenance:    return "maintenance".hashValue
            case .listOptions:    return "listOptions".hashValue
            case let .story(url): return url.hashValue
            case let .file(url):  return url.hashValue
        }
    }
}
