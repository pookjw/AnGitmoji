import CoreData

protocol GitmojiRepository: Sendable {
    var context: NSManagedObjectContext { get async throws }
    var didSaveStream: AsyncStream<Void> { get async throws }
    var newGitmojiGroup: GitmojiGroup { get async throws }
    var newGitmoji: Gitmoji { get async throws }
    func gitmojiGroups(fetchRequest: NSFetchRequest<GitmojiGroup>) async throws -> [GitmojiGroup]
    func gitmojiGroupsCount(fetchRequest: NSFetchRequest<GitmojiGroup>) async throws -> Int
    func remove(gitmojiGroup: GitmojiGroup) async throws
    func remove(gitmoji: Gitmoji) async throws
    func removeAllGitmojiGroups() async throws
    func saveChanges() async throws
}
