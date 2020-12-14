//
//  NSManagedObjectContext+Random.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import CoreData

extension NSManagedObjectContext {
    
    //  MARK: - Get Random Object(s)
    
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
