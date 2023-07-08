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
        //  FIXME: it's not safe to check just file extension
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
    
    /// Decode JSON contents of url
    /// - Returns: array of non-duplicating strings without whitespaces and newlines
    public func getTexts() throws -> [String] {
        
        guard startAccessingSecurityScopedResource()
        else {
            throw URLError.deniedAccess
        }
        
        defer { stopAccessingSecurityScopedResource() }
        
        do {
            let data = try Data(contentsOf: self)
            let decoder = JSONDecoder()
            let texts = try decoder.decode([String].self, from: data)
            
            /// remove duplicates from import
            /// this doesn't check for duplicates in store
            let noDuplicates: [String] = Set(texts).sorted()
            
            return noDuplicates.trimmed()
        } catch {
            throw URLError.readFailure
        }
    }
    
    public enum URLError: LocalizedError {
        case deniedAccess
        case readFailure
        
        public var errorDescription: String? {
            switch self {
            case .deniedAccess:
                return "Denied access to file at \(self)"
            case .readFailure:
                return "Failed to decode file at \(self)"
            }
        }
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
