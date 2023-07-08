//
//  URL+getTextsTests.swift
//  Meme-OryTests
//
//  Created by Igor Malyarov on 08.07.2023.
//

import Meme_Ory
import XCTest

final class URL_getTextsTests: XCTestCase {
    
    func test_getTexts_shouldThrowOnBadURL() {
        
        let badURL: URL = .init(string: "any-url")!
        
        XCTAssertThrowsError(
            try badURL.getTexts()
        ) {
            XCTAssertEqual(
                $0 as NSError,
                URL.URLError.deniedAccess as NSError
            )
        }
    }
}
