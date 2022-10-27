import CoreData

public protocol GitmojiUseCase: Sendable {
    // MARK: - Core Data Properties
    var context: NSManagedObjectContext { get async throws }
    var didSaveStream: AsyncStream<Void> { get async throws }
    
    // MARK: - Create
    @discardableResult func createDefaultGitmojiGroupIfNeeded() async throws -> Bool
    func createGitmojiGroup(from url: URL) async throws
    var newGitmojiGroup: GitmojiGroup { get async throws }
    func newGitmoji(to gitmojiGroup: GitmojiGroup, index: Int?) async throws -> Gitmoji
    
    // MARK: - Fetch
    func gitmojiGroups(fetchRequest: NSFetchRequest<GitmojiGroup>?) async throws -> [GitmojiGroup]
    
    // MARK: - Order
    func move(gitmojiGroup: GitmojiGroup, to index: Int) async throws
    func move(gitmoji: Gitmoji, to index: Int) async throws
    
    // MARK: - Remove
    func remove(gitmojiGroup: GitmojiGroup) async throws
    func remove(gitmoji: Gitmoji) async throws
    
    // MARK: - Save
    func saveChanges() async throws
}
