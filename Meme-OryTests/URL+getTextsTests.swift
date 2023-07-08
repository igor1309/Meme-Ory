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
        
        XCTAssertThrowsError(try badURL.getTexts()) {
            XCTAssertEqual(
                $0 as NSError,
                URL.URLError.deniedAccess as NSError
            )
        }
    }
    
    func test_getTexts_shouldThrowOnBadDataFile() throws {
        
        let badData = try testFileURL(filename: "badData")
        
        XCTAssertThrowsError(try badData.getTexts()) {
            XCTAssertEqual(
                $0 as NSError,
                URL.URLError.readFailure as NSError
            )
        }
    }
        
    // MARK: - Helpers
    
    private func testFileURL(
        filename: String,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> URL {
        
        let bundle = Bundle(for: URL_getTextsTests.self)
        
        return try XCTUnwrap(
            bundle.url(forResource: filename, withExtension: "json"),
            "Cannot found file named \"\(name).json\"",
            file: file, line: line
        )
    }
}
