import Foundation

final class GitmojiJSONRepositoryImpl: GitmojiJSONRepository {
    private let gitmojiDataSource: GitmojiJSONDataSource
    
    init(gitmojiDataSource: GitmojiJSONDataSource) {
        self.gitmojiDataSource = gitmojiDataSource
    }
    
    func gitmojiJSON(from url: URL) async throws -> GitmojiJSON {
        try await gitmojiDataSource.gitmojiJSON(from: url)
    }
    
    var defaultGitmojiJSON: GitmojiJSON {
        get async throws {
            try await gitmojiDataSource.defaultGitmojiJSON
        }
    }
    
}
