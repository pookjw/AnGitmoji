import CoreData

public protocol GitmojiUseCase: Sendable {
    // MARK: - Core Data Properties
    var context: NSManagedObjectContext { get async throws }
    
    // MARK: - Others
    var didSaveStream: AsyncStream<Void> { get async throws }
    var didInsertObjectsStream: AsyncStream<Set<NSManagedObject>> { get async throws }
    var didUpdateObjectsStream: AsyncStream<Set<NSManagedObject>> { get async throws }
    var didDeleteObjectsStream: AsyncStream<Set<NSManagedObject>> { get async throws }
    func conditionSafe<T: Sendable>(block: @Sendable () async throws -> T) async throws -> T
    func conditionSafe<T: Sendable>(block: @Sendable () async -> T) async -> T
    
    // MARK: - Create
    @discardableResult func createDefaultGitmojiGroupIfNeeded(force: Bool) async throws -> Bool
    func createGitmojiGroup(from url: URL, name: String) async throws -> GitmojiGroup
    var newGitmojiGroup: GitmojiGroup { get async throws }
    func newGitmoji(to gitmojiGroup: GitmojiGroup, index: Int?) async throws -> Gitmoji
    
    // MARK: - Fetch
    func gitmojiGroups(fetchRequest: NSFetchRequest<GitmojiGroup>?) async throws -> [GitmojiGroup]
    func gitmojiGroupsCount(fetchRequest: NSFetchRequest<GitmojiGroup>?) async throws -> Int
    
    // MARK: - Order
    func move(gitmojiGroup: GitmojiGroup, to index: Int) async throws
    func move(gitmoji: Gitmoji, to index: Int) async throws
    
    // MARK: - Remove
    func remove(gitmojiGroup: GitmojiGroup) async throws
    func remove(gitmoji: Gitmoji) async throws
    func removeAllGitmojiGroups() async throws
    
    // MARK: - Save
    func saveChanges() async throws
}
