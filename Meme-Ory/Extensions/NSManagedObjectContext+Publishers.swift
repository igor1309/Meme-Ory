//
//  NSManagedObjectContext+Publishers.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import CoreData
import Combine

extension NSManagedObjectContext {

    //  MARK: - Publishers
    
    //  MARK: Did Save
    
    var didSavePublisher: AnyPublisher<Notification, Never> {
        let sub = NotificationCenter.default
            .publisher(for: .NSManagedObjectContextDidSave)
            .filter { notification in
                let context = notification.object as? NSManagedObjectContext
                return context == self
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return sub
    }
    
    
    //  MARK: Did Change
    
    var didChangePublisher: AnyPublisher<Notification, Never> {
        let sub = NotificationCenter.default
            .publisher(for: .NSManagedObjectContextObjectsDidChange)
            .filter { notification in
                let context = notification.object as? NSManagedObjectContext
                return context == self
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return sub
    }
    
    var insertedObjectsPublisher: AnyPublisher<Set<Story>, Never> {
        let sub = didChangePublisher
            .compactMap { notification -> Set<Story>? in
                guard let insertedStories = notification.userInfo?[NSInsertedObjectsKey] as? Set<Story> else { return nil }
                return insertedStories
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return sub
    }
    
    var deletedObjectsPublisher: AnyPublisher<Set<Story>, Never> {
        let sub = didChangePublisher
            .compactMap { notification -> Set<Story>? in
                guard let insertedStories = notification.userInfo?[NSDeletedObjectsKey] as? Set<Story> else { return nil }
                return insertedStories
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return sub
    }
    
    var updatedObjectsPublisher: AnyPublisher<Set<Story>, Never> {
        let sub = didChangePublisher
            .compactMap { notification -> Set<Story>? in
                guard let insertedStories = notification.userInfo?[NSUpdatedObjectsKey] as? Set<Story> else { return nil }
                return insertedStories
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return sub
    }
    
    
}
