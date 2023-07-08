//
//  StoryImporterModelTests.swift
//  
//
//  Created by Igor Malyarov on 08.07.2023.
//

import Combine
import CombineSchedulers
import StoryImporter
import XCTest

final class StoryImporterModelTests: XCTestCase {
    
    func test_init_shouldSetStateToNil() {
        
        let (sut, spy, scheduler) = makeSUT()

        scheduler.advance()
        
        XCTAssertNil(sut.state)
        XCTAssertNoDiff(spy.values, [nil])
    }
    
    func test_init_shouldSetStateToGiven() {
        
        let initialState: StoryImporterModel.State = .texts([])
        let (sut, spy, scheduler) = makeSUT(initialState: initialState)
        
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [initialState])
        XCTAssertNotNil(sut)
    }
    
    func test_setStateToTexts_shouldNotChangeStateOnNil() {
        
        let (sut, spy, scheduler) = makeSUT()

        sut.setState(to: StoryImporterModel.State.TextsWrapper?.none)
        scheduler.advance()
                
        XCTAssertNoDiff(spy.values, [nil])
    }
    
    func test_setStateToTexts_shouldNotChangeStateOnNilTwice() {
        
        let (sut, spy, scheduler) = makeSUT()

        sut.setState(to: StoryImporterModel.State.TextsWrapper?.none)
        scheduler.advance()
        
        sut.setState(to: StoryImporterModel.State.TextsWrapper?.none)
        scheduler.advance()
                
        XCTAssertNoDiff(spy.values, [nil])
    }
    
    func test_setStateToTexts_shouldSetState() {
        
        let (sut, spy, scheduler) = makeSUT()

        sut.setState(to: .init(texts: []))
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            nil,
            .texts([])
        ])
    }
    
    func test_setStateToTexts_shouldSetStateOnceOnTwice() {
        
        let (sut, spy, scheduler) = makeSUT()

        sut.setState(to: .init(texts: []))
        scheduler.advance()
        
        sut.setState(to: .init(texts: []))
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            nil,
            .texts([])
        ])
    }
    
    func test_setStateToAlert_shouldNotChangeStateOnNil() {
        
        let (sut, spy, scheduler) = makeSUT()

        sut.setState(to: StoryImporterModel.State.AlertWrapper?.none)
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [nil])
    }
    
    func test_setStateToAlert_shouldSetState() {
        
        let (sut, spy, scheduler) = makeSUT()

        sut.setState(to: .init(message: "error"))
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
            nil,
            .alert(.init(message: "error"))
        ])
    }
    
    func test_setStateToAlert_shouldSetStateOnceOnTwice() {
        
        let (sut, spy, scheduler) = makeSUT()

        sut.setState(to: .init(message: "error"))
        scheduler.advance()
        
        sut.setState(to: .init(message: "error"))
        scheduler.advance()
        
        XCTAssertNoDiff(spy.values, [
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
        spy: ValueSpy<StoryImporterModel.State?>,
        scheduler: TestSchedulerOf<DispatchQueue>
    ) {
        let scheduler = DispatchQueue.test
        let sut = StoryImporterModel(
            initialState: initialState,
            getTexts: getTexts,
            scheduler: scheduler.eraseToAnyScheduler()
        )
        let spy = ValueSpy(sut.$state)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        trackForMemoryLeaks(scheduler, file: file, line: line)
        
        return (sut, spy, scheduler)
    }
}
