import CoreData

public protocol GitmojiUseCase: Sendable {
    @discardableResult func createDefaultGitmojiGroupIfNeeded() async throws -> Bool
    func createGitmojiGroup(from url: URL) async throws
    var context: NSManagedObjectContext { get async throws }
    var didSaveStream: AsyncStream<Void> { get async throws }
    var newGitmojiGroup: GitmojiGroup { get async throws }
    var newGitmoji: Gitmoji { get async throws }
    func gitmojiGroups(fetchRequest: NSFetchRequest<GitmojiGroup>?) async throws -> [GitmojiGroup]
    func remove(gitmojiGroup: GitmojiGroup) async throws
    func remove(gitmoji: Gitmoji) async throws
}
