//
//  ReminderLoaderTests.swift
//  
//
//  Created by Igor Malyarov on 09.07.2023.
//

import XCTest

final class ReminderStore {
    private(set) var retrieveCallCount: UInt = 0
    
    func retrieve() {
        retrieveCallCount += 1
    }
}

final class ReminderLoader {
    
    init(store: ReminderStore) {
        
    }
}

final class ReminderLoaderTests: XCTestCase {
    
    func test_init_shouldNotCallRetrieveOnReminderStore() {
        let (store, sut) = makeSUT()
        
        XCTAssertEqual(store.retrieveCallCount, 0)
        XCTAssertNotNil(sut)
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
