import SwiftUI
import Combine
import AnGitmojiCore

final class GitmojiGroupDetailViewModel: ObservableObject, @unchecked Sendable {
    @Published @MainActor private(set) var gitmojis: [Gitmoji] = []
    @Published @MainActor var selectedGitmojis: Set<Gitmoji.ID> = .init()
    @Published @MainActor var sortOrders: [KeyPathComparator<Gitmoji>] = [
        // TODO: Need to save
        .init(\.count, order: .reverse)
    ]
    private let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
    private var tasks: Set<Task<Void, Never>> = .init()
    
    init() {
        bind()
    }
    
    deinit {
        tasks.forEach { $0.cancel() }
    }
    
    func update(using selctedGitmojiGroup: GitmojiGroup?) async {
        await gitmojiUseCase.conditionSafe { [weak self] in
            var gitmojis: [Gitmoji] = selctedGitmojiGroup?.gitmoji.array as? [Gitmoji] ?? []
            
            if let sortOrders: [KeyPathComparator<Gitmoji>] = await self?.sortOrders {
                gitmojis.sort(using: sortOrders)
            }
            
            await withTaskCancellationHandler {
                await MainActor.run { [weak self, gitmojis] in
                    self?.gitmojis = gitmojis
                }
            } onCancel: {
                
            }
        }
    }
    
    func copy(from gitmoji: Gitmoji) async throws {
        UIPasteboard.general.string = gitmoji.code
        
        try await gitmojiUseCase.conditionSafe { [weak self] in
            gitmoji.count += 1
            
            try gitmoji.managedObjectContext?.save()
            try await gitmojiUseCase.saveChanges()
            
            var gitmojis: [Gitmoji] = gitmoji.group?.gitmoji.array as? [Gitmoji] ?? []
            if let sortOrders: [KeyPathComparator<Gitmoji>] = await self?.sortOrders {
                gitmojis.sort(using: sortOrders)
            }
            
            await withTaskCancellationHandler {
                await MainActor.run { [weak self, gitmojis] in
                    self?.gitmojis = gitmojis
                }
            } onCancel: {
                
            }
        }
    }
    
    func delete(at indexSet: IndexSet) async throws {
        fatalError("TODO")
    }
    
    private func bind() {
        tasks.insert(.detached { [weak self] in
            guard let sortOrders: Published<[KeyPathComparator<Gitmoji>]>.Publisher = self?.$sortOrders else {
                return
            }
            
            for await sortOrder in sortOrders.values {
                let sortedGitmojis: [Gitmoji] = await self?.gitmojis.sorted(using: sortOrder) ?? []
                await MainActor.run { [weak self] in
                    self?.gitmojis = sortedGitmojis
                }
            }
        })
    }
}
