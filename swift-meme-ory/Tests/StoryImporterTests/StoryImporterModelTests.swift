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
        let (sut, spy) = makeSUT(initialState: initialState)
        
        XCTAssertEqual(spy.values, [initialState])
        XCTAssertNotNil(sut)
    }
    
    func test_setStateToTexts_shouldNotChangeStateOnNil() {
        
        let (sut, spy) = makeSUT()

        sut.setState(to: StoryImporterModel.State.TextsWrapper?.none)
        
        XCTAssertEqual(spy.values, [nil])
    }
    
    func test_setStateToTexts_shouldSetState() {
        
        let (sut, spy) = makeSUT()

        sut.setState(to: .init(texts: []))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(spy.values, [
            nil,
            .texts([])
        ])
    }
    
    func test_setStateToAlert_shouldNotChangeStateOnNil() {
        
        let (sut, spy) = makeSUT()

        sut.setState(to: StoryImporterModel.State.AlertWrapper?.none)
        
        XCTAssertEqual(spy.values, [nil])
    }
    
    func test_setStateToAlert_shouldSetState() {
        
        let (sut, spy) = makeSUT()

        sut.setState(to: .init(message: "error"))
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertEqual(spy.values, [
            nil,
            .alert(.init(message: "error"))
        ])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        initialState: StoryImporterModel.State? = nil,
        getTexts: @escaping (URL) throws -> [String] = { _ in [] },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: StoryImporterModel,
        spy: ValueSpy<StoryImporterModel.State?>
    ) {
        
        let sut = StoryImporterModel(
            initialState: initialState,
            getTexts: getTexts
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
}
