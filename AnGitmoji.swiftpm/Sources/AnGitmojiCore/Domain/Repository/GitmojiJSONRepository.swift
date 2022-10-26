import Foundation

protocol GitmojiJSONRepository: Sendable {
    func gitmojiJSON(from url: URL) async throws -> GitmojiJSON
    var defaultGitmojiJSON: GitmojiJSON { get async throws }
}
