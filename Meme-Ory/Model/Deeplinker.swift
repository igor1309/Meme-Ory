//
//  Deeplinker.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 28.11.2020.
//

import Foundation

/// Deep Links, Universal Links, and the SwiftUI App Life Cycle | by Fernando Moya de Rivas | Better Programming | Medium
/// https://medium.com/better-programming/deep-links-universal-links-and-the-swiftui-app-life-cycle-e98e38bcef6e
///
class Deeplinker {
    enum Deeplink: Equatable {
        case home
        case story(reference: URL)
        case file(url: URL)
    }
    
    func manage(url: URL) -> Deeplink? {
        //  MARK: - FINISH THIS
        if url.absoluteString.contains(".json") {
            print("it's JSON")
            print(url)
            return .file(url: url)
        }
        
        //  MARK: - FINISH THIS
        guard url.scheme == URL.appScheme else { return nil }
        guard url.pathComponents.contains(URL.appDetailsPath) else { return .home }
        guard let query = url.query else { return nil }
        let components = query.split(separator: ",").flatMap { $0.split(separator: "=") }
        guard let idIndex = components.firstIndex(of: Substring(URL.appReferenceQueryName)) else { return nil }
        guard idIndex + 1 < components.count else { return nil }
        
        return .story(reference: url)
    }
}
