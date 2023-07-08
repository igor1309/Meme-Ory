//
//  StoryImporterModelTests.swift
//  
//
//  Created by Igor Malyarov on 08.07.2023.
//

import Combine
import StoryImporter
import XCTest

final class StoryImporterModelTests: XCTestCase {
    
    func test_init_shouldSetStateToNil() {
        
        let sut = makeSUT()
        
        XCTAssertNil(sut.state)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        state: StoryImporterModel.State? = nil,
        getTexts: @escaping (URL) throws -> [String] = { _ in [] },
        file: StaticString = #file,
        line: UInt = #line
    ) -> StoryImporterModel {
        
        let sut = StoryImporterModel(
            state: state,
            getTexts: getTexts
        )
        
         trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
