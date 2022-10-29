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
    
    func remove(gitmojiGroup: GitmojiGroup) async throws {
        let context: NSManagedObjectContext = try await context
        context.delete(gitmojiGroup)
    }
    
    func remove(gitmoji: Gitmoji) async throws {
        let context: NSManagedObjectContext = try await context
        context.delete(gitmoji)
    }
    
    func removeAllGitmojiGroups() async throws {
        let container: NSPersistentContainer = try await coreDataDataSource.container(modelName: Self.gitmojiModelName)
        
        try await context.reset()
        
        return try await withCheckedThrowingContinuation { [container, context] continuation in
            context.perform {
                do {
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = .init(entityName: Self.gitmojiGroupEntityName)
                    let batchDelete: NSBatchDeleteRequest = .init(fetchRequest: fetchRequest)
                    batchDelete.affectedStores = container.persistentStoreCoordinator.persistentStores
                    try container.persistentStoreCoordinator.execute(batchDelete, with: context)
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