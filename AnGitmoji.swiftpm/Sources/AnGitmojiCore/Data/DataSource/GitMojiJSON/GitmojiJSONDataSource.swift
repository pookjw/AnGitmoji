import Foundation

protocol GitmojiJSONDataSource: Sendable {
    func gitmojiJSON(from url: URL) async throws -> GitmojiJSON
    var defaultGitmojiJSON: GitmojiJSON { get async throws }
}
