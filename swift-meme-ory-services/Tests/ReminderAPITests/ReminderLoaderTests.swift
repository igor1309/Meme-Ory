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
    
    func test_init_shouldNotCallRetrieveOnEventStore() {
        let store = ReminderStore()
        let sut = ReminderLoader(store: store)
        
        XCTAssertEqual(store.retrieveCallCount, 0)
    }
}
