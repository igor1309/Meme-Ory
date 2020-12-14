//
//  NSManagedObjectContext+Ext.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 03.12.2020.
//

import Foundation
import CoreData
import Combine

extension NSManagedObjectContext {
    
    //  MARK: - Publishers
    
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
    
    
    //  MARK: - Real Count: non-optional count
    
    /// count func without optionality
    func realCount<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? count(for: fetchRequest)) ?? 0
    }
    
    
    //  MARK: - Save Context
    
    /// Only save if there are changes
    func saveContext() {
        guard hasChanges else { return }
        
        do {
            try self.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            /*fatalError*/ print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    //  MARK: - Get ObjectID & Object
    
    func getObjectID(for url: URL?) -> NSManagedObjectID? {
        guard let coordinator = persistentStoreCoordinator,
              let url = url,
              let coreDataURL = url.coreDataURL,
              let objectID = coordinator.managedObjectID(forURIRepresentation: coreDataURL) else { return nil }
        
        return objectID
    }
    
    func getObject(with url: URL?) -> NSManagedObject? {
        guard let objectID = getObjectID(for: url),
              let object = try? existingObject(with: objectID) else { return nil }
        
//        guard let coordinator = persistentStoreCoordinator,
//              let url = url,
//              let coreDataURL = url.coreDataURL,
//              let objectID = coordinator.managedObjectID(forURIRepresentation: coreDataURL),
//              let object = try? existingObject(with: objectID) else { return nil }
        
        return object
    }
    
    
    //  MARK: - Random
    
    func randomObject<T: NSManagedObject>(ofType type: T.Type) -> T? {
        guard let objectID = randomObjectID(ofType: type),
              let object = try? existingObject(with: objectID) else { return nil }
        
        #if DEBUG
        // print("randomObjectID: \(objectID)")
        #endif
        
        return object as? T
    }
    
    func randomObjects<T :NSManagedObject>(_ k: Int = 1, ofType type: T.Type) -> [T] {
        guard k > 0 else { return [] }
        
        let randomIDs = randomObjectIDs(k, ofType: T.self)
        
        let request = NSFetchRequest<T>()
        request.entity = T.entity()
        request.predicate = NSPredicate(format: "self IN %@", /* #keyPath(T.objectID),*/ randomIDs)
        
        guard let fetch = try? self.fetch(request) else { return [] }
        return fetch
    }
    
    fileprivate func randomObjectID<T: NSManagedObject>(ofType type: T.Type) -> NSManagedObjectID? {
        // https://stackoverflow.com/a/4792331/11793043
        let objectIdDesc = NSExpressionDescription()
        objectIdDesc.name = "objectID"
        objectIdDesc.expression = NSExpression.expressionForEvaluatedObject()
        objectIdDesc.expressionResultType = .objectIDAttributeType
        
        let request = NSFetchRequest<NSDictionary>()
        request.entity = T.entity()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [objectIdDesc]//[#keyPath(Story.text_)]
        request.returnsDistinctResults = true
        
        /// fetch all object IDs for provided type T
        guard let fetch = try? self.fetch(request) else { return nil }
        
        //print(fetch)
        let objectIDs = fetch.flatMap(\.allValues)
        //print(values)
        let randomID = objectIDs.randomElement()
        return randomID as? NSManagedObjectID
    }
    
    fileprivate func randomObjectIDs<T: NSManagedObject>(_ k: Int = 1, ofType type: T.Type) -> [NSManagedObjectID] {
        guard k > 0 else { return [] }
        
        // https://stackoverflow.com/a/4792331/11793043
        let objectIdDesc = NSExpressionDescription()
        objectIdDesc.name = "objectID"
        objectIdDesc.expression = NSExpression.expressionForEvaluatedObject()
        objectIdDesc.expressionResultType = .objectIDAttributeType
        
        let request = NSFetchRequest<NSDictionary>()
        request.entity = T.entity()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [objectIdDesc]//[#keyPath(Story.text_)]
        request.returnsDistinctResults = true
        
        /// fetch all object IDs for provided type T
        guard let fetch = try? self.fetch(request) else { return [] }
        
        let objectIDs = fetch.flatMap(\.allValues)
        let randomSlice = objectIDs.shuffled().prefix(k)
        let randomIDs = Array(randomSlice)
        return randomIDs as? [NSManagedObjectID] ?? []
    }
    
}

