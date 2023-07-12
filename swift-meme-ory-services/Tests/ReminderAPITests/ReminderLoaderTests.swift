//
//  ReminderLoaderTests.swift
//  
//
//  Created by Igor Malyarov on 09.07.2023.
//

import XCTest

struct Reminder {
    let id: UUID
}

final class ReminderStore {
    var deleteReminderCallCount: Int { deletionCompletions.count }
    var insertReminderCallCount = 0
    
    typealias DeletionCompletion = (Error?) -> Void
    private(set) var deletionCompletions = [DeletionCompletion]()
    
    func delete(
        _ reminder: Reminder,
        completion: @escaping DeletionCompletion
    ) {
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with deletionError: Error, at index: Int = 0) {
        deletionCompletions[index](deletionError)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
        insertReminderCallCount += 1
    }
}

final class ReminderLoader {
    
    private let store: ReminderStore
    
    init(store: ReminderStore) {
        self.store = store
    }
    
    func save(_ reminder: Reminder) {
        store.delete(reminder) { _ in }
    }
}

final class ReminderLoaderTests: XCTestCase {
    
    func test_init_shouldNotCallDeleteUponCreation() {
        let (store, _) = makeSUT()
        
        XCTAssertEqual(store.deleteReminderCallCount, 0)
    }
    
    func test_save_shouldRequestReminderDeletion() {
        let (store, sut) = makeSUT()
        let reminder = uniqueReminder()
        
        sut.save(reminder)
        
        XCTAssertEqual(store.deleteReminderCallCount, 1)
    }
    
    func test_save_shouldNotRequestInsertionOnDeletionError() {
        let (store, sut) = makeSUT()
        let reminder = uniqueReminder()
        let deletionError = anyNSError()
        
        sut.save(reminder)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertReminderCallCount, 0)
    }
    
    func test_save_shouldRequestInsertionOnSuccessfulDeletion() {
        let (store, sut) = makeSUT()
        let reminder = uniqueReminder()
        
        sut.save(reminder)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertReminderCallCount, 1)
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
    
    private func uniqueReminder() -> Reminder {
        .init(id: .init())
    }
}
