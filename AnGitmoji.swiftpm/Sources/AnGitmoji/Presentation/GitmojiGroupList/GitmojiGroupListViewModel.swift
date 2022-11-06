import SwiftUI
import AnGitmojiCore

final class GitmojiGroupListViewModel: ObservableObject, @unchecked Sendable {
    @Published @MainActor var searchText: String = ""
    @Published @MainActor private(set) var nsPredicate: NSPredicate?
    
    private let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
    private var tasks: Set<Task<Void, Never>> = .init()
    
    init() {
        bind()
    }
    
    deinit {
        tasks.forEach { $0.cancel() }
    }
    
    func remove(gitmojiGroup: GitmojiGroup) async throws {
        let gitmojiGroupWithBackgroundContext: GitmojiGroup = try await gitmojiUseCase.object(with: gitmojiGroup.objectID)
        try await gitmojiUseCase.remove(gitmojiGroup: gitmojiGroupWithBackgroundContext)
        try await gitmojiUseCase.saveChanges()
    }
    
    func test_removeAllGitmojiGroups() async throws {
        try await gitmojiUseCase.removeAllGitmojiGroups()
    }
    
    func test_create() async throws {
        try await gitmojiUseCase.createDefaultGitmojiGroupIfNeeded(force: true)
        try await gitmojiUseCase.saveChanges()
    }
    
    private func bind() {
        tasks.insert(.detached { [weak self] in
            guard let searchTextPublisher: Published<String>.Publisher = await self?.$searchText else {
                return
            }
            
            for await _ in searchTextPublisher.values {
                try? await Task.sleep(for: .seconds(0.3))
                await self?.updateNSPredicate()
            }
        })
    }
    
    private func updateNSPredicate() async {
        let predicate: NSPredicate?
        let searchingText: String = await searchText
        
        if searchingText.isEmpty {
            predicate = nil
        } else {
            predicate = .init(
                format: "(%K CONTAINS[cd] %@)",
                #keyPath(GitmojiGroup.name),
                searchingText
            )
        }
        
        await MainActor.run { [weak self] in
            self?.nsPredicate = predicate
        }
    }
}
