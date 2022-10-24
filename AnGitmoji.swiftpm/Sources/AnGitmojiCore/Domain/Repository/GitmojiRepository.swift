import CoreData

protocol GitmojiRepository {
    var context: NSManagedObjectContext { get async throws }
    var newGitmojiGroup: GitmojiGroup { get async throws }
    var newGitmoji: Gitmoji { get async throws }
    func gitmojiGroups(fetchRequest: NSFetchRequest<GitmojiGroup>?) async throws -> [GitmojiGroup]
    func remove(gitmojiGroup: GitmojiGroup) async throws
    func remove(gitmoji: Gitmoji) async throws
    func saveChanges() async throws
}
