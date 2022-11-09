import SwiftUI
import AnGitmojiCore
import UniformTypeIdentifiers

final class GitmojiGroupListViewModel: ObservableObject, @unchecked Sendable {
    @Published @MainActor var searchText: String = ""
    @Published @MainActor var isPresentedEditAlert: Bool = false
    @Published @MainActor var editingGitmojiGroupName: String = ""
    
    @Binding @MainActor private(set) var selectedGitmojiGroups: Set<GitmojiGroup>
    @Published @MainActor private(set) var nsPredicate: NSPredicate?
    private var editingGitmojiGroup: GitmojiGroup?
    
    private let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
    private var tasks: Set<Task<Void, Never>> = .init()
    
    init(selectedGitmojiGroups: Binding<Set<GitmojiGroup>>) {
        self._selectedGitmojiGroups = selectedGitmojiGroups
        bind()
    }
    
    deinit {
        tasks.forEach { $0.cancel() }
    }
    
    func remove(gitmojiGroup: GitmojiGroup) async throws {
        await MainActor.run { [weak self] in
            let _: GitmojiGroup? = self?.selectedGitmojiGroups.remove(gitmojiGroup)
        }
        let gitmojiGroupWithBackgroundContext: GitmojiGroup = try await gitmojiUseCase.object(with: gitmojiGroup.objectID)
        try await gitmojiUseCase.remove(gitmojiGroup: gitmojiGroupWithBackgroundContext)
        try await gitmojiUseCase.saveChanges()
    }
    
    func removeSelectedGitmojiGroups() async throws {
        let selectedGitmojiGroups: Set<GitmojiGroup> = await selectedGitmojiGroups
        
        guard !selectedGitmojiGroups.isEmpty else {
            return
        }
        
        for selectedGitmojiGroup in selectedGitmojiGroups {
            let gitmojiGroupWithBackgroundContext: GitmojiGroup = try await gitmojiUseCase.object(with: selectedGitmojiGroup.objectID)
            try await gitmojiUseCase.remove(gitmojiGroup: gitmojiGroupWithBackgroundContext)
        }
        
        try await gitmojiUseCase.saveChanges()
        
        await MainActor.run { [weak self] in
            self?.selectedGitmojiGroups = .init()
        }
    }
    
    func move(of indexSet: IndexSet, to index: Int) async throws {
        fatalError("TODO")
    }
    
    func load(itemProviders: [NSItemProvider]) async throws {
        for itemProvider in itemProviders {
            let gitmojiGroup: GitmojiGroup = try await withCheckedThrowingContinuation { continuation in
                let _: Progress = itemProvider.loadTransferable(type: GitmojiGroup.self) { result in
                    continuation.resume(with: result)
                }
            }
            
            let name: String
            if let suggestedName: String = itemProvider.suggestedName {
                name = suggestedName
            } else {
                name = "Gitmojis"
            }
            
            await gitmojiUseCase.conditionSafe {
                gitmojiGroup.name = name
            }
        }
        
        try await gitmojiUseCase.saveChanges()
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
            guard let searchTextPublisher: Published<String>.Publisher = self?.$searchText else {
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
