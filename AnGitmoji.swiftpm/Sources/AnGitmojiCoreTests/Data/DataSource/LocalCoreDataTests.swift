@preconcurrency import XCTest
@testable import AnGitmojiCore

final class LocalCoreDataTests: XCTestCase {
    private static let gitmojiModelName: String = "Gitmoji"
    private var localCoreData: LocalCoreData?
    
    override func setUp() async throws {
        localCoreData = .shared
        try await super.setUp()
    }
    
    override func tearDown() async throws {
        localCoreData = nil
        try await super.tearDown()
    }
    
    func testGetGitmojiContainer() async throws {
        let _: NSPersistentContainer = try await localCoreData!.container(modelName: Self.gitmojiModelName)
    }
    
    func testGetGitmojiContext() async throws {
        let _: NSManagedObjectContext = try await localCoreData!.context(modelName: Self.gitmojiModelName)
    }
}
