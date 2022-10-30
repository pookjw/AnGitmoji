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
    ) var fetchedGitmojiGroups: FetchedResults<GitmojiGroup>
    @Published var gitmojiGroups: [GitmojiGroup] = []
//    @Environment(\self.managedObjectContext) var context: NSManagedObjectContext = .init()
    private let gitmojiUseCase: GitmojiUseCase = DIService.gitmojiUseCase
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    init() {
        fetchedGitmojiGroups
            .publisher
            .sink { value in
                print(value)
            }
            .store(in: &cancellableBag)
    }
}
