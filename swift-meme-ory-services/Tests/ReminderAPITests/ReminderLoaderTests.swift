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
    var deleteReminderCallCount = 0
}

final class ReminderLoader {
    init(store: ReminderStore) {}
}

final class ReminderLoaderTests: XCTestCase {
    
    func test_init_shouldNotCallDeleteUponCreation() {
        let (store, _) = makeSUT()
        
        XCTAssertEqual(store.deleteReminderCallCount, 0)
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
