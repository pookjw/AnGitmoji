import Foundation
import SwiftUI
import Combine
import AnGitmojiCore

final class GitmojiGroupListViewModel: ObservableObject {
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.index, order: .forward)
        ],
        predicate: nil,
        animation: nil
    ) @MainActor var gitmojiGroups: FetchedResults<GitmojiGroup>
    private let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
}
