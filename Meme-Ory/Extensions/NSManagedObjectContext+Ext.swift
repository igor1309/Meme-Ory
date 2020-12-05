//
//  NSManagedObjectContext+Ext.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 03.12.2020.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func getObject(with url: URL?) -> NSManagedObject? {
        guard let coordinator = persistentStoreCoordinator,
              let url = url,
              let coreDataURL = url.coreDataURL,
              let objectID = coordinator.managedObjectID(forURIRepresentation: coreDataURL),
              let object = try? existingObject(with: objectID) else { return nil }
        
        return object
    }

    func randomObject<T: NSManagedObject>(ofType type: T.Type) -> T? {
        guard let objectID = randomObjectID(ofType: type),
              let object = try? existingObject(with: objectID) else { return nil }
        
        #if DEBUG
        print("randomObjectID: \(objectID)")
        #endif
        
        return object as? T
    }
    
    fileprivate func randomObjectID<T: NSManagedObject>(ofType type: T.Type) -> NSManagedObjectID? {
        // https://stackoverflow.com/a/4792331/11793043
        let objectIdDesc = NSExpressionDescription()
        objectIdDesc.name = "objectID"
        objectIdDesc.expression = NSExpression.expressionForEvaluatedObject()
        objectIdDesc.expressionResultType = .objectIDAttributeType
        
        let requestTexts = NSFetchRequest<NSDictionary>()
        requestTexts.entity = T.entity()
        requestTexts.resultType = .dictionaryResultType
        requestTexts.propertiesToFetch = [objectIdDesc]//[#keyPath(Story.text_)]
        requestTexts.returnsDistinctResults = true
        
        if let fetch = try? self.fetch(requestTexts) {
            //print(fetch)
            let values = fetch.flatMap(\.allValues)
            //print(values)
            let random = values.randomElement()
            return random as? NSManagedObjectID
        } else {
            return nil
        }
    }
    
}

