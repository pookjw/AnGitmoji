import XCTest
@testable import AnGitmojiCore

final class GitmojiJSONRepositoryImplTests: XCTestCase {
    private var gitmojiJSONRepositoryImpl: GitmojiJSONRepositoryImpl!
    
    private var defaultGitmojiURL: URL? {
        var components: URLComponents = .init()
        components.scheme = "https"
        components.host = "raw.githubusercontent.com"
        components.path = "/carloscuesta/gitmoji/master/src/data/gitmojis.json"
        
        return components.url
    }
    
    override func setUp() async throws {
        let gitmojiJSONRepositoryImpl: GitmojiJSONRepositoryImpl = .init(gitmojiDataSource: GitmojiJSONNetwork())
        self.gitmojiJSONRepositoryImpl = gitmojiJSONRepositoryImpl
        
        try await super.setUp()
    }
    
    override func tearDown() async throws {
        gitmojiJSONRepositoryImpl = nil
        try await super.tearDown()
    }
    
    func testGitmojiJSON() async throws {
        let gitmojiJSON: GitmojiJSON = try await gitmojiJSONRepositoryImpl.gitmojiJSON(from: defaultGitmojiURL!)
        XCTAssertFalse(gitmojiJSON.gitmojis.isEmpty)
    }
    
    func testDefaultGitmojiJSON() async throws {
        let gitmojiJSON: GitmojiJSON = try await gitmojiJSONRepositoryImpl.defaultGitmojiJSON
        XCTAssertFalse(gitmojiJSON.gitmojis.isEmpty)
    }
}
