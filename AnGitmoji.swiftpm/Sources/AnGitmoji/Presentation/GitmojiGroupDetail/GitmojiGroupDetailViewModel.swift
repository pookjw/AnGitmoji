@preconcurrency import SwiftUI
@preconcurrency import Combine
@preconcurrency import CoreData
import AnGitmojiCore

actor GitmojiGroupDetailViewModel: ObservableObject, @unchecked Sendable {
    @Published @MainActor var selectedGitmojis: Set<Gitmoji.ID> = .init()
    @Published @MainActor var keyPathComparators: [KeyPathComparator<Gitmoji>] = [
        // TODO: Need to save
        .init(\.code, order: .forward)
    ]
    @Published @MainActor var searchText: String = ""
    @Published @MainActor var isPresentedEditAlert: Bool = false
    @Published @MainActor var editingGitmojiEmoji: String = ""
    @Published @MainActor var editingGitmojiCode: String = ""
    @Published @MainActor var editingGitmojiName: String = ""
    @Published @MainActor var editingGitmojiDetail: String = ""
    
    @Published @MainActor private(set) var gitmojis: [Gitmoji] = []
    @Published @MainActor private(set) var sortDescriptors: [SortDescriptor<Gitmoji>] = []
    @Published @MainActor private(set) var nsPredicate: NSPredicate = .init(value: false)
    @Published @MainActor private(set) var selectedGitmojiGroupName: String = ""
    private var editingGitmoji: Gitmoji?
    
    private let selectedGitmojiGroup: GitmojiGroup
    
    private let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
    private var tasks: Set<Task<Void, Never>> = .init()
    
    init(selectedGitmojiGroup: GitmojiGroup) {
        self.selectedGitmojiGroup = selectedGitmojiGroup
        bind()
        load()
    }
    
    deinit {
        tasks.forEach { $0.cancel() }
    }
    
    func copy(gitmoji: Gitmoji) async throws {
        UIPasteboard.general.string = gitmoji.code
        
        try await gitmojiUseCase.conditionSafe { [gitmojiUseCase] in
            let gitmojiWithBackgroundContext: Gitmoji = try await gitmojiUseCase.object(with: gitmoji.objectID)
            gitmojiWithBackgroundContext.count += 1
            
            try await gitmojiUseCase.saveChanges()
        }
    }
    
    func remove(gitmoji: Gitmoji) async throws {
        let gitmojiWithBackgroundContext: Gitmoji = try await gitmojiUseCase.object(with: gitmoji.objectID)
        try await gitmojiUseCase.remove(gitmoji: gitmojiWithBackgroundContext)
        try await gitmojiUseCase.saveChanges()
    }
    
    func resetCount(gitmoji: Gitmoji) async throws {
        try await gitmojiUseCase.conditionSafe { [gitmojiUseCase] in
            let gitmojiWithBackgroundContext: Gitmoji = try await gitmojiUseCase.object(with: gitmoji.objectID)
            gitmojiWithBackgroundContext.count = .zero
            
            try await gitmojiUseCase.saveChanges()
        }
    }
    
    func prepareEditAlert(gitmoji: Gitmoji) async {
        editingGitmoji = gitmoji
        
        await gitmojiUseCase.conditionSafe { [weak self] in
            let emoji: String = gitmoji.emoji
            let code: String = gitmoji.code
            let name: String = gitmoji.name
            let detail: String = gitmoji.detail
            
            await MainActor.run { [weak self] in
                self?.editingGitmojiEmoji = emoji
                self?.editingGitmojiCode = code
                self?.editingGitmojiName = name
                self?.editingGitmojiDetail = detail
                self?.isPresentedEditAlert = true
            }
        }
    }
    
    func endEditAlert(finished: Bool) async throws {
        guard finished else {
            await clearEditAlertData()
            return
        }
        
        guard let editingGitmoji: Gitmoji = editingGitmoji else {
            await clearEditAlertData()
            return
        }
        
        let emoji: String = await editingGitmojiEmoji
        let code: String = await editingGitmojiCode
        let name: String = await editingGitmojiName
        let detail: String = await editingGitmojiDetail
        
        await clearEditAlertData()
        
        try await gitmojiUseCase.conditionSafe { [gitmojiUseCase] in
            guard editingGitmoji.managedObjectContext != nil else {
                throw AGMError.objectWasDeleted
            }
            
            let gitmojiWithBackgroundContext: Gitmoji = try await gitmojiUseCase.object(with: editingGitmoji.objectID)
            
            gitmojiWithBackgroundContext.emoji = emoji
            gitmojiWithBackgroundContext.code = code
            gitmojiWithBackgroundContext.name = name
            gitmojiWithBackgroundContext.detail = detail
            
            try await gitmojiUseCase.saveChanges()
        }
    }
    
    func edit(gitmoji: Gitmoji, emoji: String, code: String, name: String, detail: String) async throws {
        try await gitmojiUseCase.conditionSafe { [gitmojiUseCase] in
            guard gitmoji.managedObjectContext != nil else {
                throw AGMError.objectWasDeleted
            }
            
            gitmoji.emoji = emoji
            gitmoji.code = code
            gitmoji.name = name
            gitmoji.detail = detail
            
            try await gitmojiUseCase.saveChanges()
        }
    }
    
    private nonisolated func bind() {
        Task { [weak self, gitmojiUseCase] in
            // When sortOrders is updated, apply that changes to Data Source (gitmojis).
            await self?.insert(task: .detached { [weak self] in
                guard let keyPathComparatorsPublisher: Published<[KeyPathComparator<Gitmoji>]>.Publisher = await self?.$keyPathComparators else {
                    return
                }
                
                for await _ in keyPathComparatorsPublisher.values {
                    await self?.updateSortDescriptors()
                }
            })
            
            // When searchText is updated, apply that changes to Data Source (gitmojis).
            await self?.insert(task: .detached { [weak self] in
                guard let searchTextPublisher: Published<String>.Publisher = await self?.$searchText else {
                    return
                }
                
                for await _ in searchTextPublisher.values {
                    try? await Task.sleep(for: .seconds(0.3))
                    await self?.updateNSPredicate()
                }
            })
            
            // When properties of selectedGitmojiGroup is updated, update UI properties.
            await self?.insert(task: .detached { [weak self, gitmojiUseCase] in
                do {
                    for await updatedObjects in try await gitmojiUseCase.didUpdateObjectsStream {
                        guard let selectedGitmojiGroup: GitmojiGroup = self?.selectedGitmojiGroup else {
                            continue
                        }
                        
                        if let updatedGitmojiGroup: GitmojiGroup = updatedObjects
                            .filter({ $0.objectID == selectedGitmojiGroup.objectID })
                            .compactMap({ $0 as? GitmojiGroup })
                            .first
                        {
                            await gitmojiUseCase.conditionSafe { [weak self] in
                                let name: String = updatedGitmojiGroup.name
                                await MainActor.run { [weak self] in
                                    self?.selectedGitmojiGroupName = name
                                }
                            }
                        }
                    }
                } catch {
                    fatalError(error.localizedDescription)
                }
            })
        }
    }
    
    private nonisolated func load() {
        Task { [weak self] in
            await self?.insert(task: .detached { [weak self] in
                await self?.updateNSPredicate()
                
                let name: String = self?.selectedGitmojiGroup.name ?? ""
                await MainActor.run { [weak self] in
                    self?.selectedGitmojiGroupName = name
                }
            })
        }
    }
    
    private func insert(task: Task<Void, Never>) {
        tasks.insert(task)
    }
    
    private func updateNSPredicate() async {
        let predicate: NSPredicate
        
        let searchingText: String = await searchText
        if searchingText.isEmpty {
            predicate = .init(
                format: "(%K == %@)",
                #keyPath(Gitmoji.group),
                selectedGitmojiGroup
            )
        } else {
            predicate = .init(
                format: "(%K == %@) && ((%K CONTAINS[cd] %@) || (%K CONTAINS[cd] %@) || (%K CONTAINS[cd] %@) || (%K CONTAINS[cd] %@))",
                #keyPath(Gitmoji.group),
                selectedGitmojiGroup,
                #keyPath(Gitmoji.emoji),
                searchingText,
                #keyPath(Gitmoji.name),
                searchingText,
                #keyPath(Gitmoji.code),
                searchingText,
                #keyPath(Gitmoji.detail),
                searchingText
            )
        }
        
        await MainActor.run { [weak self] in
            self?.nsPredicate = predicate
        }
    }
    
    private func updateSortDescriptors() async {
        var hasCodeSortDescriptor: Bool = false
        var sortDescriptors: [SortDescriptor<Gitmoji>] = await keyPathComparators.compactMap { keyPathComparator in
            // PartialKeyPath<Gitmoji> -> KeyPath<Gitmoji, V>
            switch keyPathComparator.keyPath {
            case \.emoji:
                return .init(\.emoji, order: keyPathComparator.order)
            case \.name:
                return .init(\.name, order: keyPathComparator.order)
            case \.code:
                hasCodeSortDescriptor = true
                return .init(\.code, order: keyPathComparator.order)
            case \.detail:
                return .init(\.detail, order: keyPathComparator.order)
            case \.count:
                return .init(\.count, order: keyPathComparator.order)
            default:
                return nil
            }
        }
        
        if !hasCodeSortDescriptor {
            sortDescriptors.insert(.init(\.code, order: .reverse), at: 0)
        }
        
        await MainActor.run { [weak self, sortDescriptors] in
            self?.sortDescriptors = sortDescriptors
        }
    }
    
    private func clearEditAlertData() async {
        editingGitmoji = nil
        await MainActor.run { [weak self] in
            self?.editingGitmojiEmoji = ""
            self?.editingGitmojiCode = ""
            self?.editingGitmojiName = ""
            self?.editingGitmojiDetail = ""
            self?.isPresentedEditAlert = false
        }
    }
}
