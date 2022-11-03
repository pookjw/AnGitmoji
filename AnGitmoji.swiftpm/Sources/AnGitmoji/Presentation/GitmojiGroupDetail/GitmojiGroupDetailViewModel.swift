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
            try await gitmojiUseCase.saveChanges()
        }
    }
    
    private nonisolated func bind() {
        Task { [weak self] in
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
}
