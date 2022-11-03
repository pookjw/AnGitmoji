import SwiftUI
import AnGitmojiCore

final class GitmojiGroupListViewModel: ObservableObject {
    private let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
    private var tasks: Set<Task<Void, Never>> = .init()
    
    init() {
        
    }
    
    func remove(gitmojiGroup: GitmojiGroup) async throws {
        guard let gitmojiGroupContext: NSManagedObjectContext = gitmojiGroup.managedObjectContext else {
            return
        }
        
        let context: NSManagedObjectContext = try await gitmojiUseCase.context
        
        if gitmojiGroupContext == context {
            try await gitmojiUseCase.remove(gitmojiGroup: gitmojiGroup)
        } else {
            gitmojiGroupContext.delete(gitmojiGroup)
            try gitmojiGroupContext.save()
        }
        
        try await gitmojiUseCase.saveChanges()
    }
    
    func test_removeAllGitmojiGroups() async throws {
        try await gitmojiUseCase.removeAllGitmojiGroups()
    }
}
