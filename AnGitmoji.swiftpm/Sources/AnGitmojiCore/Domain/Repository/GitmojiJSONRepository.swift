import Foundation

protocol GitmojiJSONRepository {
    func gitmojiJSON(from url: URL) async throws -> GitmojiJSON
    var defaultGitmojiJSON: GitmojiJSON { get async throws }
}
