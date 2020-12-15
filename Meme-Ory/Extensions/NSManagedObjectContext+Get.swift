//
//  NSManagedObjectContext+Get.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import CoreData

extension NSManagedObjectContext {
    
    //  MARK: - Get ObjectID & Object
    
    func getObjectID(for url: URL?) -> NSManagedObjectID? {
        guard let coordinator = persistentStoreCoordinator,
              let url = url,
              let coreDataURL = url.coreDataURL,
              let objectID = coordinator.managedObjectID(forURIRepresentation: coreDataURL) else { return nil }
        
        return objectID
    }
    
//    func getObject(with url: URL?) -> NSManagedObject? {
//        guard let objectID = getObjectID(for: url),
//              let object = try? existingObject(with: objectID) else { return nil }
//
//        return object
//    }
    
    func getObject<T: NSManagedObject>(with url: URL?) -> T? {
        guard let objectID = getObjectID(for: url),
              let object = try? existingObject(with: objectID) as? T else { return nil }

        return object
    }
    
    
    //  MARK: - Get Tag with name
    
    func getTag(withName name: String) -> Tag {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Tag.name_), name)
        let request = Tag.fetchRequest(predicate)
        
        if let fetch = try? self.fetch(request),
           let tag = fetch.first {
            return tag
        } else {
            let tag = Tag(context: self)
            tag.name = name
            self.saveContext()
            return tag
        }
    }
    
}
