//
//  Persistence.swift
//  POCCoreData
//
//  Created by Saket Raje on 25/04/2024.
//

import CoreData

class CoreDataManager {
    // Making it a singleton by adding static
    static let instance = CoreDataManager()
    
    let container : NSPersistentContainer
    let context : NSManagedObjectContext
    
    init() {
        self.container = NSPersistentContainer(name: "POCCoreData")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error found while loading the Persistend Data. Here is the Error: \(error.localizedDescription)")
            }
            
        }
        
        context = container.viewContext
    }
    
    func save() {
        do {
            try context.save()
            print("Saved Successfully")
        } catch let error{
            print("\(error.localizedDescription)")
        }
        
        
    }
}
