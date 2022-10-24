import Foundation

protocol GitmojiJSONDataSource {
    func gitmojiJSON(from url: URL) async throws -> GitmojiJSON
}
