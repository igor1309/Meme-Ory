//
//  Ext+Calendar.Component.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 26.11.2020.
//

import Foundation

extension Calendar.Component {
    var str: String {
        switch self {
            case .day:          return "tomorrow"
            case .weekOfYear:   return "in a week"
            case .month:        return "in a month"
            case .year:         return "in a year"
            default:            return "ERROR"
        }
    }
}
