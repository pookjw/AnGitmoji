import CoreData

final class GitmojiUseCaseImpl: GitmojiUseCase, GitmojiUseCaseObjCRepresentable {
    private let gitmojiRepository: GitmojiRepository
    private let gitmojiJSONRepository: GitmojiJSONRepository
    
    init(gitmojiRepository: GitmojiRepository, gitmojiJSONRepository: GitmojiJSONRepository) {
        self.gitmojiRepository = gitmojiRepository
        self.gitmojiJSONRepository = gitmojiJSONRepository
    }
    
    public var context: NSManagedObjectContext {
        get async throws {
            return try await gitmojiRepository.context
        }
    }
    
    public func context() async throws -> NSManagedObjectContext {
        return try await context
    }
    
    public var didSaveStream: AsyncStream<Void> {
        get async throws {
            return try await gitmojiRepository.didSaveStream
        }
    }
    
    public var didInsertObjectsStream: AsyncStream<Set<NSManagedObject>> {
        get async throws {
            return try await gitmojiRepository.didInsertObjectsStream
        }
    }
    
    public var didUpdateObjectsStream: AsyncStream<Set<NSManagedObject>> {
        get async throws {
            return try await gitmojiRepository.didUpdateObjectsStream
        }
    }
    
    public var didDeleteObjectsStream: AsyncStream<Set<NSManagedObject>> {
        get async throws {
            return try await gitmojiRepository.didDeleteObjectsStream
        }
    }
    
    public func conditionSafe<T: Sendable>(block: @Sendable () async throws -> T) async throws -> T {
        return try await gitmojiRepository.conditionSafe(block: block)
    }
    
    public func conditionSafe<T: Sendable>(block: @Sendable () async -> T) async -> T where T : Sendable {
        return await gitmojiRepository.conditionSafe(block: block)
    }
    
    public func _conditionSafe(block: @Sendable @escaping () -> Void) async {
//        await conditionSafe(block: block)
        fatalError("asynchronous block is not supported on Obj-C.")
    }
    
    public func refresh(object: NSManagedObject) async throws {
        try await gitmojiRepository.refresh(object: object)
    }
    
    public func jsonData(from gitmojiGroup: GitmojiGroup) async throws -> Data {
        let gitmojiJSON: GitmojiJSON = try await createGitmojiJSON(from: gitmojiGroup)
        let encoder: JSONEncoder = .init()
        encoder.outputFormatting = .prettyPrinted
        let result: Data = try encoder.encode(gitmojiJSON)
        return result
    }
    
    @discardableResult public func createDefaultGitmojiGroupIfNeeded(force: Bool) async throws -> GitmojiGroup? {
        let fetchRequest: NSFetchRequest<GitmojiGroup> = GitmojiGroup.fetchRequest
        fetchRequest.includesSubentities = true
        fetchRequest.includesPendingChanges = true
        let count: Int = try await gitmojiRepository.gitmojiGroupsCount(fetchRequest: fetchRequest)
        
        guard (count == .zero) || force else {
            return nil
        }
        
        return try await conditionSafe {
            let defaultGitmojiJSON: GitmojiJSON = try await gitmojiJSONRepository.defaultGitmojiJSON
            let gitmojiGroup: GitmojiGroup = try await createGitmojiGroup(from: defaultGitmojiJSON)
            gitmojiGroup.name = "carloscuesta's Gitmojis"
            gitmojiGroup.index = count
            return gitmojiGroup
        }
    }
    
    public func createGitmojiGroup(from url: URL, name: String) async throws -> GitmojiGroup {
        try await conditionSafe {
            let gitmojiJSON: GitmojiJSON = try await gitmojiJSONRepository.gitmojiJSON(from: url)
            let gitmojiGroup: GitmojiGroup = try await createGitmojiGroup(from: gitmojiJSON)
            gitmojiGroup.name = name
            return gitmojiGroup
        }
    }
    
    public var newGitmojiGroup: GitmojiGroup {
        get async throws {
            try await conditionSafe {
                let fetchRequest: NSFetchRequest<GitmojiGroup> = GitmojiGroup.fetchRequest
                fetchRequest.includesSubentities = true
                fetchRequest.includesPendingChanges = true
                let count: Int = try await gitmojiRepository.gitmojiGroupsCount(fetchRequest: fetchRequest)
                
                let newGitmojiGroup: GitmojiGroup = try await gitmojiRepository.newGitmojiGroup
                newGitmojiGroup.index = count
                
                return newGitmojiGroup
            }
        }
    }
    
    public func newGitmojiGroup() async throws -> GitmojiGroup {
        return try await newGitmojiGroup
    }
    
    public func newGitmoji(to gitmojiGroup: GitmojiGroup, index: Int?) async throws -> Gitmoji {
        try await conditionSafe {
            if let index: Int, gitmojiGroup.gitmojis.count < index {
                throw AGMError.outOfIndex
            }
            let gitmoji: Gitmoji = try await gitmojiRepository.newGitmoji
            
            if let index: Int {
                gitmojiGroup.insertIntoGitmojis(gitmoji, at: index)
            } else {
                gitmojiGroup.addToGitmojis(gitmoji)
            }
            
            return gitmoji
        }
    }
    
    public func _newGitmoji(to gitmojiGroup: GitmojiGroup, index: Int) async throws -> Gitmoji {
        return try await newGitmoji(to: gitmojiGroup, index: index)
    }
    
    public func _newGitmoji(to gitmojiGroup: GitmojiGroup) async throws -> Gitmoji {
        return try await newGitmoji(to: gitmojiGroup, index: nil)
    }
    
    public func gitmojiGroups(fetchRequest: NSFetchRequest<GitmojiGroup>?) async throws -> [GitmojiGroup] {
        let fetchRequest: NSFetchRequest<GitmojiGroup> = fetchRequest ?? GitmojiGroup.fetchRequest
        let sortDescriptor: NSSortDescriptor = .init(key: #keyPath(GitmojiGroup.index), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return try await gitmojiRepository.gitmojiGroups(fetchRequest: fetchRequest)
    }
    
    public func gitmojis(fetchRequest: NSFetchRequest<Gitmoji>?) async throws -> [Gitmoji] {
        let fetchRequest: NSFetchRequest<Gitmoji> = fetchRequest ?? Gitmoji.fetchRequest
        return try await gitmojiRepository.gitmojis(fetchRequest: fetchRequest)
    }
    
    public func gitmojiGroupsCount(fetchRequest: NSFetchRequest<GitmojiGroup>?) async throws -> Int {
        let fetchRequest: NSFetchRequest<GitmojiGroup> = fetchRequest ?? GitmojiGroup.fetchRequest
        fetchRequest.includesSubentities = true
        return try await gitmojiRepository.gitmojiGroupsCount(fetchRequest: fetchRequest)
    }
    
    public func object<T>(with objectID: NSManagedObjectID) async throws -> T where T : NSManagedObject & Sendable {
        return try await gitmojiRepository.object(with: objectID)
    }
    
    public func object(with objectID: NSManagedObjectID) async throws -> NSManagedObject {
        return try await gitmojiRepository.object(with: objectID)
    }
    
    public func move(gitmojiGroup: GitmojiGroup, to index: Int) async throws {
        try await conditionSafe {
            let currentIndex: Int = gitmojiGroup.index
            
            guard currentIndex != index else {
                return
            }
            
            let gitmojiGroups: [GitmojiGroup] = try await gitmojiGroups(fetchRequest: nil)
            guard gitmojiGroups.count > index else {
                throw AGMError.outOfIndex
            }
            
            if currentIndex < index {
                let affectedIndexRange: ClosedRange<Int> = (currentIndex + 1)...index
                affectedIndexRange.forEach { affectedIndex in
                    let gitmojiGroup: GitmojiGroup = gitmojiGroups[affectedIndex]
                    gitmojiGroup.index = (affectedIndex - 1)
                }
                gitmojiGroup.index = index
            } else if currentIndex > index {
                let affectedIndexRange: ClosedRange<Int> = index...(currentIndex - 1)
                affectedIndexRange.forEach { affectedIndex in
                    let gitmojiGroup: GitmojiGroup = gitmojiGroups[affectedIndex]
                    gitmojiGroup.index = (affectedIndex + 1)
                }
                gitmojiGroup.index = index
            }
        }
    }
    
    public func move(gitmoji: Gitmoji, to index: Int) async throws {
        try await conditionSafe {
            guard let gitmojiGroup: GitmojiGroup = gitmoji.group else {
                throw AGMError.noGitmojiGroup
            }
            
            guard gitmojiGroup.gitmojis.count > index else {
                throw AGMError.outOfIndex
            }
            
            let currentIndex: Int = gitmojiGroup.gitmojis.index(of: gitmoji)
            
            guard currentIndex != NSNotFound else {
                throw AGMError.gotNSNotFound
            }
            
            guard currentIndex != index else {
                 return
            }
            
            gitmojiGroup.removeFromGitmojis(gitmoji)
            gitmojiGroup.insertIntoGitmojis(gitmoji, at: index)
        }
    }
    
    public func remove(gitmojiGroup: GitmojiGroup) async throws {
        return try await gitmojiRepository.remove(gitmojiGroup: gitmojiGroup)
    }
    
    public func remove(gitmoji: Gitmoji) async throws {
        return try await gitmojiRepository.remove(gitmoji: gitmoji)
    }
    
    public func removeAllGitmojiGroups() async throws {
        return try await gitmojiRepository.removeAllGitmojiGroups()
    }
    
    public func saveChanges() async throws {
        try await gitmojiRepository.saveChanges()
    }
    
    private func createGitmojiGroup(from gitmojiJSON: GitmojiJSON) async throws -> GitmojiGroup {
        let newGitmojiGroup: GitmojiGroup = try await gitmojiRepository.newGitmojiGroup
        
        for object in gitmojiJSON.gitmojis {
            let gitmoji: Gitmoji = try await gitmojiRepository.newGitmoji
            gitmoji.map(from: object)
            newGitmojiGroup.addToGitmojis(gitmoji)
        }
        
        try await gitmojiRepository.saveChanges()
        return newGitmojiGroup
    }
    
    private func createGitmojiJSON(from gitmojiGroup: GitmojiGroup) async throws -> GitmojiJSON {
        return try await conditionSafe {
            let gitmojiJSONObjects: [GitmojiJSON.Object] = try gitmojiGroup
                .gitmojis
                .compactMap { object throws -> GitmojiJSON.Object? in
                    guard let gitmoji: Gitmoji = object as? Gitmoji else {
                        return nil
                    }
                    
                    let emoji: String = gitmoji.emoji
                    let emojiNumericReferencesValue: [UInt32] = emoji
                        .unicodeScalars
                        .map { $0.value }
                    let entity: String = emojiNumericReferencesValue
                        .map { "&#\($0);" }
                        .joined()
                    
                    let result: GitmojiJSON.Object = .init(
                        emoji: emoji,
                        entity: entity,
                        code: gitmoji.code,
                        description: gitmoji.detail,
                        name: gitmoji.name,
                        semver: gitmoji.semver
                    )
                    
                    return result
                }
            
            let result: GitmojiJSON = .init(gitmojis: gitmojiJSONObjects)
            return result
        }
    }
}
