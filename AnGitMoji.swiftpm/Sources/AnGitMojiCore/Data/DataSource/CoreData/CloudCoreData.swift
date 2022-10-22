import Foundation
import CoreData

@globalActor
actor CloudCoreData: AGMCoreData {
    static let shared: CloudCoreData = .init()
    private var containers: [String: NSPersistentCloudKitContainer] = [:]
    private var contexts: [String: NSManagedObjectContext] = [:]
    
    private init() {}
    
    func container(entityName: String) async throws -> NSPersistentCloudKitContainer {
        if let container: NSPersistentCloudKitContainer = containers[entityName] {
            return container
        }
        
        guard let momdURL: URL = Bundle.module.url(forResource: entityName, withExtension: "mom")?.appendingPathExtension(entityName).appendingPathExtension("momd") else {
            throw AGMError.failedToFoundMomdURL(entityName: entityName)
        }
        
        guard let managedObjectModel: NSManagedObjectModel = .init(contentsOf: momdURL) else {
            throw AGMError.failedToInitManagedObjectModel(entityName: entityName)
        }
        
        let container: NSPersistentCloudKitContainer = .init(name: entityName, managedObjectModel: managedObjectModel)
        
        let _: NSPersistentStoreDescription = try await withCheckedThrowingContinuation { continuation in
            container.loadPersistentStores { description, error in
                if let error: Error {
                    continuation.resume(with: .failure(error))
                    return
                }
                continuation.resume(with: .success(description))
            }
        }
        
        containers[entityName] = container
        
        return container
    }
    
    func context(entityName: String) async throws -> NSManagedObjectContext {
        if let context: NSManagedObjectContext = contexts[entityName] {
            return context
        }
        
        let container: NSPersistentContainer = try await container(entityName: entityName)
        let context: NSManagedObjectContext = container.newBackgroundContext()
        
        contexts[entityName] = context
        
        return context
    }
}
