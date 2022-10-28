import CoreData

public final class GitmojiUseCaseImpl: GitmojiUseCase {
    private let gitmojiRepository: GitmojiRepository
    private let gitmojiJSONRepository: GitmojiJSONRepository
    private var fetchRequest: NSFetchRequest<GitmojiGroup> {
        let fetchRequest: NSFetchRequest<GitmojiGroup> = .init(entityName: "GitmojiGroup")
        return fetchRequest
    }
    
    init(gitmojiRepository: GitmojiRepository, gitmojiJSONRepository: GitmojiJSONRepository) {
        self.gitmojiRepository = gitmojiRepository
        self.gitmojiJSONRepository = gitmojiJSONRepository
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
    
    public func createDefaultGitmojiGroupIfNeeded() async throws -> Bool {
        let fetchRequest: NSFetchRequest<GitmojiGroup> = fetchRequest
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
    
    public var newGitmojiGroup: GitmojiGroup {
        get async throws {
            let fetchRequest: NSFetchRequest<GitmojiGroup> = fetchRequest
            let count: Int = try await gitmojiRepository.gitmojiGroupsCount(fetchRequest: fetchRequest)
            
            let newGitmojiGroup: GitmojiGroup = try await gitmojiRepository.newGitmojiGroup
            newGitmojiGroup.index = count
            
            return newGitmojiGroup
        }
    }
    
    public func newGitmoji(to gitmojiGroup: GitmojiGroup, index: Int?) async throws -> Gitmoji {
        let gitmoji: Gitmoji = try await gitmojiRepository.newGitmoji
        
        if let index: Int {
            gitmojiGroup.insertIntoGitmoji(gitmoji, at: index)
        } else {
            gitmojiGroup.addToGitmoji(gitmoji)
        }
        
        return gitmoji
    }
    
    public func gitmojiGroups(fetchRequest: NSFetchRequest<GitmojiGroup>?) async throws -> [GitmojiGroup] {
        let fetchRequest: NSFetchRequest<GitmojiGroup> = fetchRequest ?? self.fetchRequest
        let sortDescriptor: NSSortDescriptor = .init(key: #keyPath(GitmojiGroup.index), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return try await gitmojiRepository.gitmojiGroups(fetchRequest: fetchRequest)
    }
    
    public func move(gitmojiGroup: GitmojiGroup, to index: Int) async throws {
        guard gitmojiGroup.index != index else {
            return
        }
        
        let gitmojiGroups: [GitmojiGroup] = try await gitmojiGroups(fetchRequest: nil)
        guard gitmojiGroups.count > index else {
            throw AGMError.outOfIndex
        }
        
        let currentIndex: Int = gitmojiGroup.index
        
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
    
    public func move(gitmoji: Gitmoji, to index: Int) async throws {
        guard let gitmojiGroup: GitmojiGroup = gitmoji.group else {
            throw AGMError.noGitmojiGroup
        }
        
        guard gitmojiGroup.gitmoji.count > index else {
            throw AGMError.outOfIndex
        }
        
        let currentIndex: Int = gitmojiGroup.gitmoji.index(of: gitmoji)
        
        guard currentIndex != NSNotFound else {
            throw AGMError.gotNSNotFound
        }
        
        let toBeReplaced: IndexSet
        if currentIndex < index {
            toBeReplaced = .init(integersIn: currentIndex...index)
        } else if currentIndex > index {
            toBeReplaced = .init(integersIn: index...currentIndex)
        } else {
            return
        }
        
        guard var toBeReplacedObjects: [Gitmoji] = gitmojiGroup.gitmoji.objects(at: toBeReplaced) as? [Gitmoji] else {
            throw AGMError.failedToCastType
        }
        
        toBeReplacedObjects.swapAt(currentIndex, index)
        gitmojiGroup.replaceGitmoji(at: toBeReplaced as NSIndexSet, with: toBeReplacedObjects)
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
