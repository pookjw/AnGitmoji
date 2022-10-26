import XCTest
@testable import AnGitmojiCore

final class GitmojiJSONNetworkTests: XCTestCase {
    private var defaultGitmojiURL: URL? {
        var components: URLComponents = .init()
        components.scheme = "https"
        components.host = "raw.githubusercontent.com"
        components.path = "/carloscuesta/gitmoji/master/src/data/gitmojis.json"
        
        return components.url
    }
    private var gitmojiJSONNetwork: GitmojiJSONNetwork?
    
    override func setUp() async throws {
        gitmojiJSONNetwork = .init()
        try await super.setUp()
    }
    
    override func tearDown() async throws {
        gitmojiJSONNetwork = nil
        try await super.tearDown()
    }
    
    func testGitmojiJSON() async throws {
        let result: GitmojiJSON = try await gitmojiJSONNetwork!.gitmojiJSON(from: defaultGitmojiURL!)
        XCTAssertFalse(result.gitmojis.isEmpty)
    }
    
    func testDefaultGitmojiJSON() async throws {
        let result: GitmojiJSON = try await gitmojiJSONNetwork!.defaultGitmojiJSON
        XCTAssertFalse(result.gitmojis.isEmpty)
    }
}
