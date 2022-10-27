import CoreData

public final class GitmojiUseCaseImpl: GitmojiUseCase {
    private let gitmojiRepository: GitmojiRepository
    private let gitmojiJSONRepository: GitmojiJSONRepository
    
    private static let gitmojiGroupEntityName: String = "GitmojiGroup"
    
    init(gitmojiRepository: GitmojiRepository, gitmojiJSONRepository: GitmojiJSONRepository) {
        self.gitmojiRepository = gitmojiRepository
        self.gitmojiJSONRepository = gitmojiJSONRepository
    }
    
    public func createDefaultGitmojiGroupIfNeeded() async throws -> Bool {
        let fetchRequest: NSFetchRequest<GitmojiGroup> = .init(entityName: Self.gitmojiGroupEntityName)
        fetchRequest.includesSubentities = true
        let count: Int = try await gitmojiRepository.gitmojiGroupsCount(fetchRequest: fetchRequest)
        
        guard count == .zero else {
            return false
        }
        
        let defaultGitmojiJSON: GitmojiJSON = try await gitmojiJSONRepository.defaultGitmojiJSON
        try await createGitmojiGroup(from: defaultGitmojiJSON)
        return true
    }
    
    public func createGitmojiGroup(from url: URL) async throws {
        let gitmojiJSON: GitmojiJSON = try await gitmojiJSONRepository.gitmojiJSON(from: url)
        try await createGitmojiGroup(from: gitmojiJSON)
    }
    
    public var context: NSManagedObjectContext {
        get async throws {
            return try await gitmojiRepository.context
        }
    }
    
    public var didSaveStream: AsyncStream<Void> {
        get async throws {
            return try await gitmojiRepository.didSaveStream
        }
    }
    
    public var newGitmojiGroup: GitmojiGroup {
        get async throws {
            let fetchRequest: NSFetchRequest<GitmojiGroup> = .init(entityName: Self.gitmojiGroupEntityName)
            let count: Int = try await gitmojiRepository.gitmojiGroupsCount(fetchRequest: fetchRequest)
            
            let newGitmojiGroup: GitmojiGroup = try await gitmojiRepository.newGitmojiGroup
            newGitmojiGroup.order = .init(integerLiteral: count)
            
            return newGitmojiGroup
        }
    }
    
    public var newGitmoji: Gitmoji {
        get async throws {
            return try await gitmojiRepository.newGitmoji
        }
    }
    
    public func gitmojiGroups(fetchRequest: NSFetchRequest<GitmojiGroup>?) async throws -> [GitmojiGroup] {
        let fetchRequest: NSFetchRequest<GitmojiGroup> = fetchRequest ?? .init(entityName: Self.gitmojiGroupEntityName)
        let sortDescriptor: NSSortDescriptor = .init(key: #keyPath(GitmojiGroup.order), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return try await gitmojiRepository.gitmojiGroups(fetchRequest: fetchRequest)
    }
    
    public func remove(gitmojiGroup: GitmojiGroup) async throws {
        return try await gitmojiRepository.remove(gitmojiGroup: gitmojiGroup)
    }
    
    public func remove(gitmoji: Gitmoji) async throws {
        return try await gitmojiRepository.remove(gitmoji: gitmoji)
    }
    
    private func createGitmojiGroup(from gitmojiJSON: GitmojiJSON) async throws {
        let newGitmojiGroup: GitmojiGroup = try await gitmojiRepository.newGitmojiGroup
        
        for object in gitmojiJSON.gitmojis {
            let gitmoji: Gitmoji = try await gitmojiRepository.newGitmoji
            gitmoji.map(from: object)
            newGitmojiGroup.addToGitmoji(gitmoji)
        }
        
        try await gitmojiRepository.saveChanges()
    }
}
