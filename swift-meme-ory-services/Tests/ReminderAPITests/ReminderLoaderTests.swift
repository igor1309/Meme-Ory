//
//  ReminderLoaderTests.swift
//  
//
//  Created by Igor Malyarov on 09.07.2023.
//

import XCTest

struct Reminder {
    let id: String
}

final class ReminderStore {
    typealias RetrieveResult = Result<Reminder, Error>
    typealias RetrieveCompletion = (RetrieveResult) -> Void
    
    private var retrieveCompletions = [RetrieveCompletion]()
    
    var retrieveCallCount: Int {
        retrieveCompletions.count
    }
    
    func retrieve(completion: @escaping RetrieveCompletion) {
        retrieveCompletions.append(completion)
    }
    
    func completeRetrieve(with error: Error, at index: Int = 0) {
        retrieveCompletions[index](.failure(error))
    }
    
    func completeRetrieveSuccessfully(with reminder: Reminder, at index: Int = 0) {
        retrieveCompletions[index](.success(reminder))
    }
}

final class ReminderLoader {
    
    typealias RetrieveResult = Result<Reminder, Error>
    typealias RetrieveCompletion = (RetrieveResult) -> Void
    
    private let store: ReminderStore
    
    init(store: ReminderStore) {
        self.store = store
    }
    
    func retrieve(completion: @escaping RetrieveCompletion) {
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

        assert(expect: .failure(retrieveError), sut: sut) {
            store.completeRetrieve(with: retrieveError)
        }
    }
    
    func test_retrieve_shouldDeliverReminderOnReminderStoreSuccessfulRetrieve() {
        let (store, sut) = makeSUT()
        let retrieveReminder = Reminder(id: "abc")
        
        assert(expect: .success(.init(id: "abc")), sut: sut) {
            store.completeRetrieveSuccessfully(with: retrieveReminder)
        }
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
    
    private func assert(
        expect expectedResult: ReminderLoader.RetrieveResult,
        sut: ReminderLoader,
        on action: @escaping () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var receivedResult: ReminderLoader.RetrieveResult?
        let expectation = expectation(description: "wait for retrieve")
        
        sut.retrieve {
            receivedResult = $0
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1)
        
        switch (receivedResult, expectedResult) {
        case let (.failure(retrieveError as NSError), .failure(expectedError as NSError)):
            XCTAssertNoDiff(retrieveError, expectedError, file: file, line: line)
            
        case let (.success(retrieveReminder), .success(expectedReminder)):
            XCTAssertNoDiff(retrieveReminder.id, expectedReminder.id, file: file, line: line)

        case let (.none, expectedResult):
            XCTFail("Expected \(expectedResult), got no result.", file: file, line: line)
            
        case let (.some(receivedResult), expectedResult):
            XCTFail("Expected \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
        }
    }
}
