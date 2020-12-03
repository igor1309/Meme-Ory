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
}

