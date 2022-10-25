import XCTest
@testable import AnGitmojiCore

private final class GitmojiJSONMockDataSource: GitmojiJSONDataSource {
    private var jsonData: Data {
        get throws {
            let jsonURL: URL = Bundle.module.url(forResource: "default_gitmojis", withExtension: "json")!
            let jsonData: Data = try .init(contentsOf: jsonURL)
            return jsonData
        }
    }
    
    func gitmojiJSON(from url: URL) async throws -> GitmojiJSON {
        let jsonData: Data = try jsonData
        let jsonDecoder: JSONDecoder = .init()
        let gitmojiJSON: GitmojiJSON = try jsonDecoder.decode(GitmojiJSON.self, from: jsonData)
        XCTAssertFalse(gitmojiJSON.gitmojis.isEmpty)
        return gitmojiJSON
    }
}

final class GitmojiJSONRepositoryImplTests: XCTestCase {
    private var gitmojiJSONRepositoryImplWithNetworkDataSource: GitmojiJSONRepositoryImpl?
    private var gitmojiJSONRepositoryImplWithMockDataSource: GitmojiJSONRepositoryImpl?
    
    private var defaultURL: URL {
        var components: URLComponents = .init()
        components.scheme = "https"
        components.host = "raw.githubusercontent.com"
        components.path = "/carloscuesta/gitmoji/master/src/data/gitmojis.json"
        
        let url: URL = components.url!
        return url
    }
    
    override func setUp() async throws {
        gitmojiJSONRepositoryImplWithNetworkDataSource = .init(gitmojiDataSource: GitmojiJSONNetwork())
        gitmojiJSONRepositoryImplWithMockDataSource = .init(gitmojiDataSource: GitmojiJSONMockDataSource())
        try await super.setUp()
    }
    
    override func tearDown() async throws {
        gitmojiJSONRepositoryImplWithNetworkDataSource = nil
        gitmojiJSONRepositoryImplWithMockDataSource = nil
        try await super.tearDown()
    }
    
    func testGitmojiJSONFromNetworkDataSource() async throws {
        let gitmojiJSON: GitmojiJSON = try await gitmojiJSONRepositoryImplWithNetworkDataSource!.gitmojiJSON(from: defaultURL)
        XCTAssertFalse(gitmojiJSON.gitmojis.isEmpty)
    }
    
    func testDefaultGitmojiJSONFromNetworkDataSource() async throws {
        let gitmojiJSON: GitmojiJSON = try await gitmojiJSONRepositoryImplWithNetworkDataSource!.defaultGitmojiJSON
        XCTAssertFalse(gitmojiJSON.gitmojis.isEmpty)
    }
    
    func testGitmojiJSONFromMockDataSource() async throws {
        let gitmojiJSON: GitmojiJSON = try await gitmojiJSONRepositoryImplWithMockDataSource!.gitmojiJSON(from: defaultURL)
        XCTAssertFalse(gitmojiJSON.gitmojis.isEmpty)
    }
    
    func testDefaultGitmojiJSONFromMockDataSource() async throws {
        let gitmojiJSON: GitmojiJSON = try await gitmojiJSONRepositoryImplWithMockDataSource!.defaultGitmojiJSON
        XCTAssertFalse(gitmojiJSON.gitmojis.isEmpty)
    }
}
