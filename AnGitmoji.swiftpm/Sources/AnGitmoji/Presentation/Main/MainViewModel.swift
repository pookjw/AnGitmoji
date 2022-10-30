import Foundation
@preconcurrency import SwiftUI
import Combine
import CoreData
import AnGitmojiCore

final class MainViewModel: ObservableObject, @unchecked Sendable {
    @Published @MainActor private(set) var context: NSManagedObjectContext?
    private let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
    private var loadingContextTask: Task<Void, Never>?
    
    deinit {
        loadingContextTask?.cancel()
    }
    
    init() {
        loadContext()
    }
    
    private func loadContext() {
        loadingContextTask = .detached { [weak self] in
            do {
                // SwiftUI/FetchCommon.swift:47: Fatal error: Can only use main queue contexts to drive SwiftUI
                let context: NSManagedObjectContext = .init(concurrencyType: .mainQueueConcurrencyType)
                context.parent = try await self?.gitmojiUseCase.context
                context.automaticallyMergesChangesFromParent = true
                await MainActor.run { [weak self, context] in
                    self?.context = context
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
}
