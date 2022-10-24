import Foundation

protocol GitmojiRepository {
    // TODO: Entity, not Data
    func gitmojiData(from url: URL) async throws -> Data
}
