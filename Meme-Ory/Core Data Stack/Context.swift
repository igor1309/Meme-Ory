//
//  Context.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 23.11.2020.
//

import CoreData

extension NSManagedObjectContext {
    
    /// count func without optionality
    func realCount<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? count(for: fetchRequest)) ?? 0
    }
    
    func saveContext() {
        if hasChanges {
            do {
                try self.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}
