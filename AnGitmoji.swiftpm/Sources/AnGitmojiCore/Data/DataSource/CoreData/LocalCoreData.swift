import Foundation
@preconcurrency import CoreData

@globalActor
actor LocalCoreData: CoreDataDataSource {
    static let shared: LocalCoreData = .init()
    private var containers: [String: NSPersistentContainer] = [:]
    private var contexts: [String: NSManagedObjectContext] = [:]
    
    private init() {}
    
    func container(modelName: String) async throws -> NSPersistentContainer {
        if let container: NSPersistentContainer = containers[modelName] {
            return container
        }
        
        guard let momdURL: URL = Bundle.module.url(forResource: modelName, withExtension: "mom", subdirectory: "\(modelName).momd") else {
            throw AGMError.failedToFoundMomdURL(modelName: modelName)
        }
        
        guard let managedObjectModel: NSManagedObjectModel = .init(contentsOf: momdURL) else {
            throw AGMError.failedToInitManagedObjectModel(modelName: modelName)
        }
        
        let container: NSPersistentContainer = .init(name: modelName, managedObjectModel: managedObjectModel)
        
        let _: NSPersistentStoreDescription = try await withCheckedThrowingContinuation { continuation in
            container.loadPersistentStores { description, error in
                if let error: Error {
                    continuation.resume(with: .failure(error))
                    return
                }
                continuation.resume(with: .success(description))
            }
        }
        
        containers[modelName] = container
        
        return container
    }
    
    func context(modelName: String) async throws -> NSManagedObjectContext {
        if let context: NSManagedObjectContext = contexts[modelName] {
            return context
        }
        
        let container: NSPersistentContainer = try await container(modelName: modelName)
        let context: NSManagedObjectContext = container.newBackgroundContext()
        context.mergePolicy = NSOverwriteMergePolicy
        
        contexts[modelName] = context
        
        return context
    }
}
