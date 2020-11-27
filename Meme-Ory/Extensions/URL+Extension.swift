//
//  URL+Extension.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 25.11.2020.
//

import Foundation

extension URL {
    var isStoryURL: Bool {
        guard scheme == URL.appScheme else {
            // print("scheme is NOT OK")
            return false }
        guard pathComponents.contains(URL.appDetailsPath) else {
            // print("appDetailsPath is NOT OK")
            return false }

        return true
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


//  not used but keep as idea
private class Deeplinker {
    enum Deeplink: Equatable {
        case home
        case details(reference: String)
    }
    
    func manage(url: URL) -> Deeplink? {
        guard url.scheme == URL.appScheme else { return nil }
        guard url.pathComponents.contains(URL.appDetailsPath) else { return .home }
        guard let query = url.query else { return nil }
        let components = query.split(separator: ",").flatMap { $0.split(separator: "=") }
        guard let idIndex = components.firstIndex(of: Substring(URL.appReferenceQueryName)) else { return nil }
        guard idIndex + 1 < components.count else { return nil }
        
        return .details(reference: String(components[idIndex.advanced(by: 1)]))
    }
}
