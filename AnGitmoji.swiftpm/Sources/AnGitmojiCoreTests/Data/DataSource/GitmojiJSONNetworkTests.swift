import XCTest
@testable import AnGitmojiCore

final class GitmojiJSONNetworkTests: XCTestCase {
    private var gitmojiJSONNetwork: GitmojiJSONNetwork?
    
    override func setUp() async throws {
        gitmojiJSONNetwork = .init()
        try await super.setUp()
    }
    
    override func tearDown() async throws {
        gitmojiJSONNetwork = nil
        try await super.tearDown()
    }
    
    func testDownloadFromDefaultURL() async throws {
        var components: URLComponents = .init()
        components.scheme = "https"
        components.host = "raw.githubusercontent.com"
        components.path = "/carloscuesta/gitmoji/master/src/data/gitmojis.json"
        
        let url: URL = components.url!
        
        let result: GitmojiJSON = try await gitmojiJSONNetwork!.gitmojiJSON(from: url)
        XCTAssertFalse(result.gitmojis.isEmpty)
    }
}
