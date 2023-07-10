//
//  ReminderLoaderTests.swift
//  
//
//  Created by Igor Malyarov on 09.07.2023.
//

import XCTest

struct Reminder {}

final class ReminderStore {
    private(set) var retrieveCallCount: UInt = 0
    
    typealias RetrieveCompletion = (Error) -> Void
    private var retrieveCompletions = [RetrieveCompletion]()
    
    func retrieve(completion: @escaping RetrieveCompletion) {
        retrieveCallCount += 1
        retrieveCompletions.append(completion)
    }
    
    func completeRetrieve(with error: Error, at index: Int = 0) {
        retrieveCompletions[index](error)
    }
    
    func completeRetrieveSuccessfully() {
        
    }
}

final class ReminderLoader {
    
    private let store: ReminderStore
    
    init(store: ReminderStore) {
        self.store = store
    }
    
    func retrieve(completion: @escaping (Error) -> Void) {
        store.retrieve(completion: completion)
    }
}

final class ReminderLoaderTests: XCTestCase {
    
    func test_init_shouldNotCallRetrieveOnReminderStore() {
        let (store, sut) = makeSUT()
        
        XCTAssertEqual(store.retrieveCallCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_retrieve_shouldCallRetrieveOnReminderStore() {
        let (store, sut) = makeSUT()
        
        sut.retrieve { _ in }
        
        XCTAssertEqual(store.retrieveCallCount, 1)
    }
    
    func test_retrieve_shouldDeliverErrorOnReminderStoreError() {
        let (store, sut) = makeSUT()
        let retrieveError = anyNSError()
        var receivedError: Error?
        let expectation = expectation(description: "wait for retrieve")
        
        sut.retrieve {
            receivedError = $0
            expectation.fulfill()
        }
        store.completeRetrieve(with: retrieveError)
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertNoDiff(receivedError as? NSError, retrieveError)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        store: ReminderStore,
        sut: ReminderLoader
    ) {
        let store = ReminderStore()
        let sut = ReminderLoader(store: store)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (store, sut)
    }
}
