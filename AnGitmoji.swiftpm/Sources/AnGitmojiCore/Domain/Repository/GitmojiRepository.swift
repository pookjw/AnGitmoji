import CoreData

protocol GitmojiRepository: Sendable {
    var context: NSManagedObjectContext { get async throws }
    var didSaveStream: AsyncStream<Void> { get async throws }
    var didInsertObjectsStream: AsyncStream<Set<NSManagedObject>> { get async throws }
    var didUpdateObjectsStream: AsyncStream<Set<NSManagedObject>> { get async throws }
    var didDeleteObjectsStream: AsyncStream<Set<NSManagedObject>> { get async throws }
    func refresh(object: NSManagedObject) async throws
    var newGitmojiGroup: GitmojiGroup { get async throws }
    var newGitmoji: Gitmoji { get async throws }
    func gitmojiGroups(fetchRequest: NSFetchRequest<GitmojiGroup>) async throws -> [GitmojiGroup]
    func gitmojiGroupsCount(fetchRequest: NSFetchRequest<GitmojiGroup>) async throws -> Int
    func object<T>(with objectID: NSManagedObjectID) async throws -> T where T : NSManagedObject & Sendable
    func remove(gitmojiGroup: GitmojiGroup) async throws
    func remove(gitmoji: Gitmoji) async throws
    func removeAllGitmojiGroups() async throws
    func saveChanges() async throws
    func conditionSafe<T: Sendable>(block: @Sendable () async throws -> T) async throws -> T
    func conditionSafe<T: Sendable>(block: @Sendable () async -> T) async -> T
}
