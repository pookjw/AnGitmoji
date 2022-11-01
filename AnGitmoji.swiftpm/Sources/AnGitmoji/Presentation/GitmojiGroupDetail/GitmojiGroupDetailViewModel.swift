import SwiftUI
import Combine
@preconcurrency import CoreData
import AnGitmojiCore

actor GitmojiGroupDetailViewModel: ObservableObject, @unchecked Sendable {
    @Published @MainActor private(set) var gitmojis: [Gitmoji] = []
    @Published @MainActor var selectedGitmojis: Set<Gitmoji.ID> = .init()
    @Published @MainActor var sortOrders: [KeyPathComparator<Gitmoji>] = [
        // TODO: Need to save
        .init(\.count, order: .reverse)
    ]
    private var selectedGitmojiGroup: GitmojiGroup?
    private let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
    private var tasks: Set<Task<Void, Never>> = .init()
    
    init() {
        bind()
    }
    
    deinit {
        tasks.forEach { $0.cancel() }
    }
    
    func update(using selectedGitmojiGroup: GitmojiGroup?) async {
        self.selectedGitmojiGroup = selectedGitmojiGroup
        await updateGitmojis()
    }
    
    func copy(from gitmoji: Gitmoji) async throws {
        UIPasteboard.general.string = gitmoji.code
        
        try await gitmojiUseCase.conditionSafe { [gitmojiUseCase] in
            gitmoji.count += 1
            
            try gitmoji.managedObjectContext?.save()
            try await gitmojiUseCase.saveChanges()
        }
    }
    
    func delete(at indexSet: IndexSet) async throws {
        fatalError("TODO")
    }
    
    private nonisolated func bind() {
        Task { [weak self, gitmojiUseCase] in
            // When sortOrders is changed, apply that changes to Data Source (gitmojis).
            await self?.insert(task: .detached { [weak self] in
                guard let sortOrders: Published<[KeyPathComparator<Gitmoji>]>.Publisher = await self?.$sortOrders else {
                    return
                }
                
                for await _ in sortOrders.values {
                    await self?.updateGitmojis()
                }
            })
            
            // When Gitmojis is updated, reload the Data Source.
            await self?.insert(task: .detached { [weak self, gitmojiUseCase] in
                do {
                    for await updatedObjects in try await gitmojiUseCase.didUpdateObjectsStream {
                        await gitmojiUseCase.conditionSafe { [weak self] in
                            guard let gitmojis: Set<Gitmoji> = await self?.selectedGitmojiGroup?.gitmojis.set as? Set<Gitmoji> else {
                                return
                            }
                            let updatedObjectIDs: Set<NSManagedObjectID> = .init(updatedObjects.map { $0.objectID })
                            let gitmojiObjectIds: Set<NSManagedObjectID> = .init(gitmojis.map { $0.objectID} )
                            
                            guard !(updatedObjectIDs.intersection(gitmojiObjectIds).isEmpty) else {
                                return
                            }
                            
                            await self?.updateGitmojis()
                        }
                    }
                } catch {
                    fatalError("\(error)")
                }
            })
        }
    }
    
    private func insert(task: Task<Void, Never>) {
        tasks.insert(task)
    }
    
    // TODO: Use NSFetchRequest
    private func updateGitmojis() async {
        await gitmojiUseCase.conditionSafe { [weak self] in
            var gitmojis: [Gitmoji] = await self?.selectedGitmojiGroup?.gitmojis.array as? [Gitmoji] ?? []
            if let sortOrders: [KeyPathComparator<Gitmoji>] = await self?.sortOrders {
                gitmojis.sort(using: sortOrders)
            }
            
            await MainActor.run { [weak self, gitmojis] in
                self?.gitmojis = gitmojis
            }
        }
    }
}
