@preconcurrency import SwiftUI
@preconcurrency import Combine
@preconcurrency import CoreData
import AnGitmojiCore

actor GitmojiGroupDetailViewModel: ObservableObject, @unchecked Sendable {
    @Published @MainActor var selectedGitmojiGroup: GitmojiGroup?
    @Published @MainActor var selectedGitmojis: Set<Gitmoji.ID> = .init()
    @Published @MainActor var keyPathComparators: [KeyPathComparator<Gitmoji>] = [
        // TODO: Need to save
        .init(\.code, order: .forward)
    ]
    @Published @MainActor var isPresentedEditAlert: Bool = false
    @Published @MainActor var editingGitmoji: Gitmoji?
    @Published @MainActor var editingGitmojiEmoji: String = ""
    @Published @MainActor var editingGitmojiCode: String = ""
    @Published @MainActor var editingGitmojiName: String = ""
    @Published @MainActor var editingGitmojiDetail: String = ""
    
    @Published @MainActor private(set) var gitmojis: [Gitmoji] = []
    @Published @MainActor private(set) var sortDescriptors: [SortDescriptor<Gitmoji>] = []
    @Published @MainActor private(set) var nsPredicate: NSPredicate?
    
    private let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
    private var tasks: Set<Task<Void, Never>> = .init()
    
    init() {
        bind()
    }
    
    deinit {
        tasks.forEach { $0.cancel() }
    }
    
    func copy(gitmoji: Gitmoji) async throws {
        UIPasteboard.general.string = gitmoji.code
        
        try await gitmojiUseCase.conditionSafe { [gitmojiUseCase] in
            gitmoji.count += 1
            
            // Push to parent
            try gitmoji.managedObjectContext?.save()
            
            try await gitmojiUseCase.saveChanges()
        }
    }
    
    func remove(gitmoji: Gitmoji) async throws {
        try await gitmojiUseCase.remove(gitmoji: gitmoji)
        try await gitmojiUseCase.saveChanges()
    }
    
    func resetCount(gitmoji: Gitmoji) async throws {
        try await gitmojiUseCase.conditionSafe { [gitmojiUseCase] in
            gitmoji.count = .zero
            
            // Push to parent
            try gitmoji.managedObjectContext?.save()
            
            try await gitmojiUseCase.saveChanges()
        }
    }
    
    func prepareEditAlert(gitmoji: Gitmoji) async {
        await gitmojiUseCase.conditionSafe { [weak self] in
            let emoji: String = gitmoji.emoji
            let code: String = gitmoji.code
            let name: String = gitmoji.name
            let detail: String = gitmoji.detail
            
            await MainActor.run { [weak self] in
                self?.editingGitmoji = gitmoji
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
        
        guard let editingGitmoji: Gitmoji = await editingGitmoji else {
            return
        }
        let emoji: String = await editingGitmojiEmoji
        let code: String = await editingGitmojiCode
        let name: String = await editingGitmojiName
        let detail: String = await editingGitmojiDetail
        
        await clearEditAlertData()
        
        try await gitmojiUseCase.conditionSafe { [gitmojiUseCase] in
            guard editingGitmoji.managedObjectContext != nil else {
                throw AGMError.gitmojiWasDeleted
            }
            
            editingGitmoji.emoji = emoji
            editingGitmoji.code = code
            editingGitmoji.name = name
            editingGitmoji.detail = detail
            
            // Push to parent
            try editingGitmoji.managedObjectContext?.save()
            
            try await gitmojiUseCase.saveChanges()
        }
    }
    
    func edit(gitmoji: Gitmoji, emoji: String, code: String, name: String, detail: String) async throws {
        try await gitmojiUseCase.conditionSafe { [gitmojiUseCase] in
            guard gitmoji.managedObjectContext != nil else {
                throw AGMError.gitmojiWasDeleted
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
            // When selectedGitmojiGroup is updated, load the Data Source.
            await self?.insert(task: .detached { [weak self] in
                guard let selectedGitmojiGroupPublisher: Published<GitmojiGroup?>.Publisher = await self?.$selectedGitmojiGroup else {
                    return
                }
                
                for await _ in selectedGitmojiGroupPublisher.values {
                    await self?.updateGitmojis()
                }
            })
            
            // When sortOrders is updated, apply that changes to Data Source (gitmojis).
            await self?.insert(task: .detached { [weak self] in
                guard let keyPathComparatorsPublisher: Published<[KeyPathComparator<Gitmoji>]>.Publisher = await self?.$keyPathComparators else {
                    return
                }
                
                for await _ in keyPathComparatorsPublisher.values {
                    await self?.updateGitmojis()
                }
            })
            
            // Detect when selectedGitmojiGroup is deleted.
            await self?.insert(task: .detached { [weak self, gitmojiUseCase] in
                do {
                    for await deletedObjects in try await gitmojiUseCase.didDeleteObjectsStream {
                        let selectedGitmojiGroup: GitmojiGroup? = await self?.selectedGitmojiGroup
                        
                        if deletedObjects.contains(where: { deletedObject in
                            return deletedObject.objectID == selectedGitmojiGroup?.objectID
                        }) {
                            
                            await MainActor.run { [weak self] in
                                self?.clearEditAlertData()
                                self?.selectedGitmojiGroup = nil
                            }
                        }
                    }
                } catch {
                    fatalError("\(error.localizedDescription)")
                }
            })
        }
    }
    
    private func insert(task: Task<Void, Never>) {
        tasks.insert(task)
    }
    
    private func updateGitmojis() async {
        let predicate: NSPredicate = await .init(format: "%K = %@", argumentArray: [#keyPath(Gitmoji.group), selectedGitmojiGroup])
        
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
            self?.nsPredicate = predicate
            self?.sortDescriptors = sortDescriptors
        }
    }
    
    @MainActor private func clearEditAlertData() {
        editingGitmoji = nil
        editingGitmojiEmoji = ""
        editingGitmojiCode = ""
        editingGitmojiName = ""
        editingGitmojiDetail = ""
        isPresentedEditAlert = false
    }
}
