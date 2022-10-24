import XCTest
@testable import AnGitmojiCore

final class GitmojiJSONTests: XCTestCase {
    private var jsonData: Data {
        get throws {
            let jsonURL: URL = Bundle.module.url(forResource: "default_gitmojis", withExtension: "json")!
            let jsonData: Data = try .init(contentsOf: jsonURL)
            return jsonData
        }
    }
    
    func testDecoding() async throws {
        let jsonData: Data = try jsonData
        let jsonDecoder: JSONDecoder = .init()
        let gitmojiJSON: GitmojiJSON = try jsonDecoder.decode(GitmojiJSON.self, from: jsonData)
        XCTAssertFalse(gitmojiJSON.gitmojis.isEmpty)
    }
    
    func testEncoding() async throws {
        let jsonData: Data = try jsonData
        let jsonDecoder: JSONDecoder = .init()
        let gitmojiJSON: GitmojiJSON = try jsonDecoder.decode(GitmojiJSON.self, from: jsonData)
        XCTAssertFalse(gitmojiJSON.gitmojis.isEmpty)
        
        let jsonEncoder: JSONEncoder = .init()
        let _: Data = try jsonEncoder.encode(gitmojiJSON)
    }
}
