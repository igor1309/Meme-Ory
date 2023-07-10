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
    
    private let store: ReminderStore
    
    init(store: ReminderStore) {
        self.store = store
    }
    
    func retrieve(completion: @escaping ReminderStore.RetrieveCompletion) {
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
            switch $0 {
            case let .failure(error):
                receivedError = error
                expectation.fulfill()
                
            case let .success(reminder):
                XCTFail("Expected error, got \(reminder) instead.")
            }
        }
        store.completeRetrieve(with: retrieveError)
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertNoDiff(receivedError as? NSError, retrieveError)
    }
    
    func test_retrieve_shouldDeliverReminderOnReminderStoreSuccessfulRetrieve() {
        let (store, sut) = makeSUT()
        let retrieveReminder = Reminder(id: "abc")
        var receivedReminder: Reminder?
        let expectation = expectation(description: "wait for retrieve")
        
        sut.retrieve {
            switch $0 {
            case let .failure(error):
                XCTFail("Expected reminder, got \(error) instead.")
                
            case let .success(reminder):
                receivedReminder = reminder
                expectation.fulfill()
            }
        }
        store.completeRetrieveSuccessfully(with: retrieveReminder)
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertNoDiff(receivedReminder?.id, retrieveReminder.id)
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
