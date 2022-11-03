import Foundation
import SwiftUI
import Combine
import CoreData
import AnGitmojiCore

final class MainViewModel: ObservableObject, @unchecked Sendable {
    @Published @MainActor private(set) var context: NSManagedObjectContext?
    private let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
    private var tasks: Set<Task<Void, Never>> = .init()
    
    deinit {
        tasks.forEach { $0.cancel() }
    }
    
    init() {
        loadContext()
        createDefaultGitmojisGroupIfNeeded()
    }
    
    private func loadContext() {
        tasks.insert(.detached { [weak self] in
            do {
                // SwiftUI/FetchCommon.swift:47: Fatal error: Can only use main queue contexts to drive SwiftUI
                let context: NSManagedObjectContext = .init(concurrencyType: .mainQueueConcurrencyType)
                context.parent = try await self?.gitmojiUseCase.context
                context.automaticallyMergesChangesFromParent = true
                context.mergePolicy = NSOverwriteMergePolicy
                
                await MainActor.run { [weak self, context] in
                    self?.context = context
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        })
    }
    
    private func createDefaultGitmojisGroupIfNeeded() {
        tasks.insert(.detached { [gitmojiUseCase] in
            do {
                try await gitmojiUseCase.createDefaultGitmojiGroupIfNeeded(force: false)
                try await gitmojiUseCase.saveChanges()
            } catch {
                fatalError(error.localizedDescription)
            }
        })
    }
}
