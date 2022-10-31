import SwiftUI
import AnGitmojiCore

final class GitmojiGroupListViewModel: ObservableObject, Sendable {
    private let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
    
    init() {
        
    }
    
    func test_create() {
        Task {
            try await gitmojiUseCase.createDefaultGitmojiGroupIfNeeded(force: true)
            try await gitmojiUseCase.saveChanges()
        }
    }
    
    func test_removeAll() {
        Task {
            try await gitmojiUseCase.removeAllGitmojiGroups()
        }
    }
}
