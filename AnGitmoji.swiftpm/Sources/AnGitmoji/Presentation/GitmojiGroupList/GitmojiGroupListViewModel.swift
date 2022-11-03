import SwiftUI
import AnGitmojiCore

final class GitmojiGroupListViewModel: ObservableObject {
    private let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
    private var tasks: Set<Task<Void, Never>> = .init()
    
    init() {
        
    }
    
    func remove(gitmojiGroup: GitmojiGroup) async throws {
        try await gitmojiUseCase.remove(gitmojiGroup: gitmojiGroup)
        try await gitmojiUseCase.saveChanges()
    }
    
    func test_removeAllGitmojiGroups() async throws {
        try await gitmojiUseCase.removeAllGitmojiGroups()
    }
    
    func test_create() async throws {
        try await gitmojiUseCase.createDefaultGitmojiGroupIfNeeded(force: true)
        try await gitmojiUseCase.saveChanges()
    }
}
