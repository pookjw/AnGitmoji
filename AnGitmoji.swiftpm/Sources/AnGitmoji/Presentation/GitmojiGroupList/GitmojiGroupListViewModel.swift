import SwiftUI
import AnGitmojiCore

final class GitmojiGroupListViewModel: ObservableObject, @unchecked Sendable {
    @Published @MainActor var searchText: String = ""
    @Published @MainActor var isPresentedEditAlert: Bool = false
    @Published @MainActor var editingGitmojiGroupName: String = ""
    
    @Published @MainActor private(set) var nsPredicate: NSPredicate?
    private var editingGitmojiGroup: GitmojiGroup?
    
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
    
    func move(of indexSet: IndexSet, to index: Int) async throws {
        
    }
    
    func prepareEditAlert(gitmojiGroup: GitmojiGroup) async {
        editingGitmojiGroup = gitmojiGroup
        
        await gitmojiUseCase.conditionSafe { [weak self] in
            let name: String = gitmojiGroup.name
            
            await MainActor.run { [weak self] in
                self?.editingGitmojiGroupName = name
                self?.isPresentedEditAlert = true
            }
        }
    }
    
    func endEditAlert(finished: Bool) async throws {
        guard finished else {
            await clearEditAlertData()
            return
        }
        
        guard let editingGitmojiGroup: GitmojiGroup = editingGitmojiGroup else {
            await clearEditAlertData()
            return
        }
        
        let name: String = await editingGitmojiGroupName
        
        await clearEditAlertData()
        
        try await gitmojiUseCase.conditionSafe { [gitmojiUseCase] in
            guard editingGitmojiGroup.managedObjectContext != nil else {
                throw AGMError.objectWasDeleted
            }
            
            let gitmojiGroupWithBackgroundContext: GitmojiGroup = try await gitmojiUseCase.object(with: editingGitmojiGroup.objectID)
            
            gitmojiGroupWithBackgroundContext.name = name
            
            try await gitmojiUseCase.saveChanges()
        }
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
    
    private func clearEditAlertData() async {
        editingGitmojiGroup = nil
        await MainActor.run { [weak self] in
            self?.editingGitmojiGroupName = ""
            self?.isPresentedEditAlert = false
        }
    }
}
