//
//  PersistantManager.swift
//  Feed
//
//  Created by Abhayjeet Singh on 29/06/23.
//

import Foundation

import CoreData

final class PersistantManager {
    static let shared = PersistantManager()
    static private let DBName = "Movie"
    static private let entityName = "FeedsEntity"
    private init() {
        
    }
    
    // Set up Core Data model and context
    
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: DBName)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        })
        return container
    }()
    
    
    func saveSingleRecord(data: Search, completion: @escaping ((Bool)->())) {
        
        if isRecordExists(imdbID: data.imdbID) {
            return
        }
        
        let context = persistentContainer.viewContext
        
        context.performAndWait {
            guard let entity = NSEntityDescription.entity(forEntityName: PersistantManager.entityName, in: context) else {
                return
            }
            
            var id = 0
            
            if let allDbRecords = fetchRecordFromCoreData() {
                id = allDbRecords.count
            }
            
            id += 1
            
            let feedItem = FeedsEntity(entity: entity, insertInto: context)
            feedItem.id = Int32(id)
            feedItem.poster = data.poster
            feedItem.year = data.year
            feedItem.title = data.title
            feedItem.imdbID = data.imdbID
            feedItem.date = Date()
            feedItem.imageData = data.downloadedImage?.pngData()
            
            
            // Save managed object context
            do {
                try context.save()
                completion(true)
            } catch {
                completion(false)
                print("Failed to save Core Data context: \(error)")
            }
        }
    }
    
    
    func isRecordExists(imdbID: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: PersistantManager.entityName)
        fetchRequest.predicate = NSPredicate(format: "imdbID == %@", imdbID)
        let context = persistentContainer.viewContext
        
        var results: [NSManagedObject] = []
        
        do {
            results = try context.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        return results.count > 0
    }
    
    func fetchRecordFromCoreData()->[FeedsEntity]? {
        
        let context = persistentContainer.viewContext
        
        // Create a fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: PersistantManager.entityName)
        
        //Add a sort descriptor to sort the results
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true) // Replace "name" with the attribute you want to sort by
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Set the fetch limit to retrieve only the top 10 records
        //fetchRequest.fetchLimit = 10
        
        do {
            let result = try context.fetch(fetchRequest)
            return result as? [FeedsEntity]
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
            return nil
        }
    }
    
}
