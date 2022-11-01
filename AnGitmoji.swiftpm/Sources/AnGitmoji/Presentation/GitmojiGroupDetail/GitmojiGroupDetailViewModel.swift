import SwiftUI
import AnGitmojiCore

final class GitmojiGroupDetailViewModel: ObservableObject, @unchecked Sendable {
    @Published @MainActor private(set) var gitmojis: [Gitmoji]?
    @Published @MainActor var selectedGitmojis: Set<Gitmoji.ID> = .init()
    @Published @MainActor var sortOrder: [KeyPathComparator<Gitmoji>] = []
    private let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
    
    func update(using selctedGitmojiGroup: GitmojiGroup?) async {
        await gitmojiUseCase.conditionSafe {
            let gitmojis: [Gitmoji]? = selctedGitmojiGroup?.gitmoji.array as? [Gitmoji]
            await withTaskCancellationHandler {
                await MainActor.run { [weak self] in
                    self?.gitmojis = gitmojis
                }
            } onCancel: {
                
            }
        }
    }
    
    func copy(from gitmoji: Gitmoji) {
        UIPasteboard.general.string = gitmoji.code
    }
    
    func delete(at indexSet: IndexSet) {
        fatalError("TODO")
    }
}
