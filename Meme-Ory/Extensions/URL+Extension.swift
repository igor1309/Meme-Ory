//
//  URL+Extension.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 25.11.2020.
//

import Foundation

extension URL {
    func getTexts() -> [String] {
        guard let data = try? Data(contentsOf: self) else {
            print("Failed to load file from \(self)")
            return []
        }
        
        let decoder = JSONDecoder()
        
        guard let briefs = try? decoder.decode([String].self, from: data) else {
            print("Failed to decode file at \(self)")
            return []
        }
        
        /// remove duplicates from import
        /// this doesn't check for duplicates in store
        return Array(Set(briefs)).sorted()
    }
    
    func getBriefs() -> [Brief] {
        guard let data = try? Data(contentsOf: self) else {
            print("Failed to load file from \(self)")
            return []
        }
        
        let decoder = JSONDecoder()
        
        guard let briefs = try? decoder.decode([Brief].self, from: data) else {
            print("Failed to decode file at \(self)")
            return []
        }
        
        /// remove duplicates from import
        /// this doesn't check for duplicates in store
        return Array(Set(briefs)).sorted()
    }
}

/// Deep Links, Universal Links, and the SwiftUI App Life Cycle | by Fernando Moya de Rivas | Better Programming | Medium
/// https://medium.com/better-programming/deep-links-universal-links-and-the-swiftui-app-life-cycle-e98e38bcef6e
extension URL {
    static let appScheme = "meme-ory"
    static let appHost = "www.meme-ory.com"
    static let appHomeUrl = "\(Self.appScheme)://\(Self.appHost)"
    static let appDetailsPath = "details"
    static let appReferenceQueryName = "reference"
    static let appDetailsUrlFormat = "\(Self.appHomeUrl)/\(Self.appDetailsPath)?\(Self.appReferenceQueryName)=%@"
    
}
