import CoreData

@objc(GitmojiUseCase) public protocol GitmojiUseCaseObjCRepresentable: AnyObject, Sendable {
    // MARK: - Core Data Properties
    func context() async throws -> NSManagedObjectContext
    
    // MARK: - Others
    @objc(conditionSafeWithBlock:completionHandler:) func _conditionSafe(block: @Sendable @escaping () -> Void) async
    func refresh(object: NSManagedObject) async throws
    
    // MARK: - Create
    @discardableResult func createDefaultGitmojiGroupIfNeeded(force: Bool) async throws -> Bool
    func createGitmojiGroup(from url: URL, name: String) async throws -> GitmojiGroup
    func newGitmojiGroup() async throws -> GitmojiGroup
    @objc(newGitmojiTo:index:completionHandler:) func _newGitmoji(to gitmojiGroup: GitmojiGroup, index: Int) async throws -> Gitmoji
    @objc(newGitmojiTo:completionHandler:) func _newGitmoji(to gitmojiGroup: GitmojiGroup) async throws -> Gitmoji
    
    // MARK: - Fetch
    func gitmojiGroups(fetchRequest: NSFetchRequest<GitmojiGroup>?) async throws -> [GitmojiGroup]
    func gitmojiGroupsCount(fetchRequest: NSFetchRequest<GitmojiGroup>?) async throws -> Int
    func object(with objectID: NSManagedObjectID) async throws -> NSManagedObject
    
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
