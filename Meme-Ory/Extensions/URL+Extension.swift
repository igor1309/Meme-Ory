//
//  URL+Extension.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 25.11.2020.
//

import Foundation

extension URL {
    /// https://www.donnywals.com/handling-deeplinks-in-ios-14-with-onopenurl/
    enum Deeplink: Equatable {
        case home
        case story(reference: URL)
        case file(url: URL)
    }
    
    var deeplink: Deeplink? {
        //  MARK: - FINISH THIS
        // it's not safe to check just file extension
        if absoluteString.contains(".json") {
            print("deeplink: it's JSON \(self)")
            return .file(url: self)
        }
        
        //  MARK: - FINISH THIS
        guard scheme == URL.appScheme else { return nil }
        guard pathComponents.contains(URL.appDetailsPath) else { return .home }
        guard let query = query else { return nil }
        let components = query.split(separator: ",").flatMap { $0.split(separator: "=") }
        
        guard let idIndex = components.firstIndex(of: Substring(URL.appReferenceQueryName)) else { return nil }
        guard idIndex + 1 < components.count else { return nil }
        
        return .story(reference: self)
    }
    
    var coreDataURL: URL? {
        guard !absoluteString.hasPrefix("x-coredata") else { return self }
        
        //  MARK: - FINISH THIS: SAME PART IN var deeplink
        guard scheme == URL.appScheme else { return nil }
        guard pathComponents.contains(URL.appDetailsPath) else { return nil }
        guard let query = query else { return nil }
        let components = query.split(separator: ",").flatMap { $0.split(separator: "=") }
        
        // meme-ory://www.meme-ory.com/details?reference=x-coredata://50A46BEA-26D5-437F-A49D-FD1C7224B041/Story/p3
        // x-coredata://50A46BEA-26D5-437F-A49D-FD1C7224B041/Story/p3
        // x-coredata://<UUID>/<EntityName>/p<Key>
        guard components.count == 2 else { return nil }
        let coreDataString = components[1]
        guard coreDataString.hasPrefix("x-coredata") else { return nil }
        #if DEBUG
        //print(coreDataString)
        #endif
        return URL(string: String(coreDataString))
    }
}

extension URL {
    func getTexts() -> [String] {
        guard let data = try? Data(contentsOf: self) else {
            print("getTexts: Failed to load file from \(self)")
            return []
        }
        
        let decoder = JSONDecoder()
        
        guard let texts = try? decoder.decode([String].self, from: data) else {
            print("getTexts: Failed to decode file at \(self)")
            return []
        }
        
        /// remove duplicates from import
        /// this doesn't check for duplicates in store
        return Array(Set(texts)).sorted()
    }
}

/// Deep Links, Universal Links, and the SwiftUI App Life Cycle | by Fernando Moya de Rivas | Better Programming | Medium
/// https://medium.com/better-programming/deep-links-universal-links-and-the-swiftui-app-life-cycle-e98e38bcef6e
extension URL {
    static let appScheme = "meme-ory"
    static let appHost = "www.meme-ory.com"
    static let appHomeURL = "\(Self.appScheme)://\(Self.appHost)"
    static let appDetailsPath = "details"
    static let appReferenceQueryName = "reference"
    static let appDetailsURLFormat = "\(Self.appHomeURL)/\(Self.appDetailsPath)?\(Self.appReferenceQueryName)=%@"
    
}
