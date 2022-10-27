@preconcurrency import XCTest
@testable import AnGitmojiCore

final class GitmojiRepositoryRepositoryImplTests: XCTestCase {
    private static let gitmojiGroupEntityName: String = "GitmojiGroup"
    private var gitmojiRepositoryImpl: GitmojiRepositoryImpl?
    
    override func setUp() async throws {
        gitmojiRepositoryImpl = .shared
        try await super.setUp()
    }
    
    override func tearDown() async throws {
        gitmojiRepositoryImpl = nil
        try await super.tearDown()
    }
    
    func testContext() async throws {
        let _: NSManagedObjectContext = try await gitmojiRepositoryImpl!.context
    }
    
    func testNewGitmojiGroup() async throws {
        let _: GitmojiGroup = try await gitmojiRepositoryImpl!.newGitmojiGroup
    }
    
    func testNewGitmoji() async throws {
        let _: Gitmoji = try await gitmojiRepositoryImpl!.newGitmoji
    }
    
//    func testGitmojiGroups() async throws {
//        let _: [GitmojiGroup] = try await gitmojiRepositoryImpl!.gitmojiGroups(fetchRequest: nil)
//    }
//
//    func testGitmojiGroupsCount() async throws {
//        let _: Int = try await gitmojiRepositoryImpl!.gitmojiGroupsCount(fetchRequest: nil)
//    }
//
//    func testAddSaveGitmoji() async throws {
//        let gitmojiGroup: GitmojiGroup = try await gitmojiRepositoryImpl!.newGitmojiGroup
//        let gitmoji: Gitmoji = try await gitmojiRepositoryImpl!.newGitmoji
//
//        gitmojiGroup.addToGitmoji(gitmoji)
//
//        try await gitmojiRepositoryImpl!.saveChanges()
//
//        let gitmojiGroups: [GitmojiGroup] = try await gitmojiRepositoryImpl!.gitmojiGroups(fetchRequest: nil)
//        let hasSavedGitmoji: Bool = gitmojiGroups.contains { gitmojiGroup in
//            return gitmojiGroup.gitmoji.contains(gitmoji)
//        }
//        XCTAssertTrue(hasSavedGitmoji)
//    }
}
