import Foundation
import SwiftUI
import Combine
import AnGitmojiCore

final class GitmojiGroupListViewModel: ObservableObject, Sendable {
    private let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init() {
        
    }
    
    func test() {
        Task {
            try await gitmojiUseCase.createDefaultGitmojiGroupIfNeeded(force: true)
            try await gitmojiUseCase.saveChanges()
        }
    }
}
