@preconcurrency import CoreData
import Combine

@globalActor
actor GitmojiRepositoryImpl: GitmojiRepository {
    private static let gitmojiModelName: String = "Gitmoji"
    private static let gitmojiGroupEntityName: String = "GitmojiGroup"
    static let shared: GitmojiRepositoryImpl = .init(coreDataDataSource: LocalCoreData.shared)
    
    private let coreDataDataSource: any CoreDataDataSource
    
    private init(coreDataDataSource: any CoreDataDataSource) {
        self.coreDataDataSource = coreDataDataSource
    }
    
    var context: NSManagedObjectContext {
        get async throws {
            try await coreDataDataSource.context(modelName: Self.gitmojiModelName)
        }
    }
    
    var didSaveStream: AsyncStream<Void> {
        get async throws {
            let context: NSManagedObjectContext = try await context
            let didSaveStream: AsyncStream<Void> = .init { continuation in
                let task: Task = .detached(priority: .low) {
                    for await _ in NotificationCenter.default.notifications(named: NSManagedObjectContext.didSaveObjectsNotification, object: context) {
                        continuation.yield(())
                    }
                }
                
                continuation.onTermination = { _ in
                    task.cancel()
                }
            }
            
            return didSaveStream
        }
    }
    
    var didInsertObjectsStream: AsyncStream<Set<NSManagedObject>> {
        get async throws {
            let context: NSManagedObjectContext = try await context
            let didInsertObjectsStream: AsyncStream<Set<NSManagedObject>> = .init { contination in
                let task: Task = .detached(priority: .low) {
                    for await notification in NotificationCenter.default.notifications(named: .NSManagedObjectContextObjectsDidChange, object: context) {
                        guard let insertedObjects: Set<NSManagedObject> = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> else {
                            continue
                        }
                        contination.yield(with: .success(.init(insertedObjects)))
                    }
                }
                
                contination.onTermination = { _ in
                    task.cancel()
                }
            }
            
            return didInsertObjectsStream
        }
    }
    
    var didUpdateObjectsStream: AsyncStream<Set<NSManagedObject>> {
        get async throws {
            let context: NSManagedObjectContext = try await context
            let didUpdateObjectsStream: AsyncStream<Set<NSManagedObject>> = .init { contination in
                let task: Task = .detached(priority: .low) {
                    for await notification in NotificationCenter.default.notifications(named: .NSManagedObjectContextObjectsDidChange, object: context) {
                        guard let updatedObjects: Set<NSManagedObject> = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> else {
                            continue
                        }
                        contination.yield(with: .success(.init(updatedObjects)))
                    }
                }
                
                contination.onTermination = { _ in
                    task.cancel()
                }
            }
            
            return didUpdateObjectsStream
        }
    }
    
    var didDeleteObjectsStream: AsyncStream<Set<NSManagedObject>> {
        get async throws {
            let context: NSManagedObjectContext = try await context
            let didDeleteObjectsStream: AsyncStream<Set<NSManagedObject>> = .init { contination in
                let task: Task = .detached(priority: .low) {
                    for await notification in NotificationCenter.default.notifications(named: .NSManagedObjectContextObjectsDidChange, object: context) {
                        guard let deletedObjects: Set<NSManagedObject> = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> else {
                            continue
                        }
                        contination.yield(with: .success(.init(deletedObjects)))
                    }
                }
                
                contination.onTermination = { _ in
                    task.cancel()
                }
            }
            
            return didDeleteObjectsStream
        }
    }
    
    var newGitmojiGroup: GitmojiGroup {
        get async throws {
            let context: NSManagedObjectContext = try await context
            let newGitmojiGroup: GitmojiGroup = .init(context: context)
            return newGitmojiGroup
        }
    }
    
    var newGitmoji: Gitmoji {
        get async throws {
            let context: NSManagedObjectContext = try await context
            let newGitmoji: Gitmoji = .init(context: context)
            return newGitmoji
        }
    }
    
    func gitmojiGroups(fetchRequest: NSFetchRequest<GitmojiGroup>) async throws -> [GitmojiGroup] {
        let results: [GitmojiGroup] = try await withCheckedThrowingContinuation { [context] continuation in
            context.perform {
                do {
                    let results: [GitmojiGroup] = try context.fetch(fetchRequest)
                    continuation.resume(with: .success(results))
                } catch {
                    continuation.resume(with: .failure(error))
                }
            }
        }
        return results
    }
    
    func gitmojiGroupsCount(fetchRequest: NSFetchRequest<GitmojiGroup>) async throws -> Int {
        let count: Int = try await withCheckedThrowingContinuation { [context] continuation in
            context.perform {
                do {
                    let count: Int = try context.count(for: fetchRequest)
                    continuation.resume(with: .success(count))
                } catch {
                    continuation.resume(with: .failure(error))
                }
            }
        }
        
        return count
    }
    
    func object<T>(with objectID: NSManagedObjectID) async throws -> T where T : NSManagedObject & Sendable {
        let context: NSManagedObjectContext = try await context
        let result: NSManagedObject = context.object(with: objectID)
        
        guard let castedResult: T = result as? T else {
            throw AGMError.failedToCastType
        }
        
        return castedResult
    }
    
    func remove(gitmojiGroup: GitmojiGroup) async throws {
        let container: NSPersistentContainer = try await coreDataDataSource.container(modelName: Self.gitmojiModelName)
        let context: NSManagedObjectContext = try await context
        
        //
        
        let gitmojiFetchRequest: NSFetchRequest<NSFetchRequestResult> = Gitmoji.fetchRequest as! NSFetchRequest<NSFetchRequestResult>
        gitmojiFetchRequest.predicate = .init(format: "%K = %@", argumentArray: [#keyPath(Gitmoji.group), gitmojiGroup])
        let gitmojisDelete: NSBatchDeleteRequest = .init(fetchRequest: gitmojiFetchRequest)
        gitmojisDelete.affectedStores = container.persistentStoreCoordinator.persistentStores
        
        try container.persistentStoreCoordinator.execute(gitmojisDelete, with: context)
        
        // https://stackoverflow.com/a/35706560/17473716
        context.refreshAllObjects()
        
        await withCheckedContinuation { continuation in
            context.delete(gitmojiGroup)
            continuation.resume(with: .success(()))
        }
    }
    
    func remove(gitmoji: Gitmoji) async throws {
        let context: NSManagedObjectContext = try await context
        
        await withCheckedContinuation { continuation in
            context.delete(gitmoji)
            continuation.resume(with: .success(()))
        }
    }
    
    func removeAllGitmojiGroups() async throws {
        let container: NSPersistentContainer = try await coreDataDataSource.container(modelName: Self.gitmojiModelName)
        
        try await context.reset()
        
        return try await withCheckedThrowingContinuation { [container, context] continuation in
            context.perform {
                do {
                    let gitmojiGroupFetchRequest: NSFetchRequest<NSFetchRequestResult> = GitmojiGroup.fetchRequest as! NSFetchRequest<NSFetchRequestResult>
                    let gitmojiFetchRequest: NSFetchRequest<NSFetchRequestResult> = Gitmoji.fetchRequest as! NSFetchRequest<NSFetchRequestResult>
                    
                    let gitmojiGroupBatchDelete: NSBatchDeleteRequest = .init(fetchRequest: gitmojiGroupFetchRequest)
                    let gitmojiBatchDelete: NSBatchDeleteRequest = .init(fetchRequest: gitmojiFetchRequest)
                    
                    gitmojiGroupBatchDelete.affectedStores = container.persistentStoreCoordinator.persistentStores
                    gitmojiBatchDelete.affectedStores = container.persistentStoreCoordinator.persistentStores
                    
                    try container.persistentStoreCoordinator.execute(gitmojiGroupBatchDelete, with: context)
                    try container.persistentStoreCoordinator.execute(gitmojiBatchDelete, with: context)
                    
                    continuation.resume(with: .success(()))
                } catch {
                    continuation.resume(with: .failure(error))
                }
            }
        }
    }
    
    func saveChanges() async throws {
        try await withCheckedThrowingContinuation { [context] continuation in
            context.perform {
                do {
                    try context.save()
                    continuation.resume(with: .success(()))
                } catch {
                    continuation.resume(with: .failure(error))
                }
            }
        }
    }
    
    func conditionSafe<T: Sendable>(block: @Sendable () async throws -> T) async throws -> T where T : Sendable {
        return try await block()
    }
    
    func conditionSafe<T: Sendable>(block: @Sendable () async -> T) async -> T where T : Sendable {
        return await block()
    }
}
