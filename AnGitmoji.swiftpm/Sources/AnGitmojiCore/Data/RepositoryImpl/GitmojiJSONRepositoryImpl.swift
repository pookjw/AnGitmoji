import Foundation

final class GitmojiJSONRepositoryImpl: GitmojiJSONRepository {
    private let gitmojiDataSource: GitmojiJSONDataSource
    private var defaultGitmojiURL: URL? {
        // https://raw.githubusercontent.com/carloscuesta/gitmoji/master/src/data/gitmojis.json
        var components: URLComponents = .init()
        components.scheme = "https"
        components.host = "raw.githubusercontent.com"
        components.path = "/carloscuesta/gitmoji/master/src/data/gitmojis.json"
        return components.url
    }
    
    init(gitmojiDataSource: GitmojiJSONDataSource) {
        self.gitmojiDataSource = gitmojiDataSource
    }
    
    func gitmojiJSON(from url: URL) async throws -> GitmojiJSON {
        try await gitmojiDataSource.gitmojiJSON(from: url)
    }
    
    var defaultGitmojiJSON: GitmojiJSON {
        get async throws {
            guard let defaultGitmojiURL: URL else {
                throw AGMError.unexpectedNilValue
            }
            
            return try await gitmojiJSON(from: defaultGitmojiURL)
        }
    }
    
}
