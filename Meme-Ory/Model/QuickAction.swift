//
//  QuickAction.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 01.12.2020.
//

import UIKit

extension Notification.Name {
    static let QuickAction = Notification.Name("QuickAction")
    
}

enum QuickAction: String, CaseIterable {
    case pasteToNew, showFavorites
    
    // UIApplicationShortcutItemType
    var type: String {
        switch self {
            case .pasteToNew:    return rawValue.capitalized
            case .showFavorites: return rawValue.capitalized
        }
    }
        
    // UIApplicationShortcutIconTypeSearch
    var icon: UIApplicationShortcutIcon {
        switch self {
            case .pasteToNew:    return UIApplicationShortcutIcon(systemImageName: "doc.on.clipboard")
            case .showFavorites: return UIApplicationShortcutIcon(systemImageName: "star.fill")
        }
    }
    
    // UIApplicationShortcutItemTitle
    var title: String {
        switch self {
            case .pasteToNew:    return "Paste to new"
            case .showFavorites: return "Show Favorites"
        }
    }
    
    
    // UIApplicationShortcutItemSubtitle
    var subtitle: String {
        switch self {
            case .pasteToNew:    return "Clipboard to new Story"
            case .showFavorites: return ""
        }
    }
    
    func shortcutItem(userInfo: [String : NSSecureCoding]?) -> UIApplicationShortcutItem {
        UIApplicationShortcutItem(type: type, localizedTitle: title, localizedSubtitle: subtitle.isEmpty ? nil : subtitle, icon: icon, userInfo: userInfo)
    }
}
