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
        
        let (sut, spy) = makeSUT()
        
        XCTAssertNil(sut.state)
        XCTAssertEqual(spy.values, [nil])
    }
    
    func test_init_shouldSetStateToGiven() {
        
        let initialState: StoryImporterModel.State = .texts([])
        let (sut, spy) = makeSUT(state: initialState)
        
        XCTAssertEqual(spy.values, [initialState])
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        state: StoryImporterModel.State? = nil,
        getTexts: @escaping (URL) throws -> [String] = { _ in [] },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: StoryImporterModel,
        spy: ValueSpy<StoryImporterModel.State?>
    ) {
        
        let sut = StoryImporterModel(
            state: state,
            getTexts: getTexts
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
}
