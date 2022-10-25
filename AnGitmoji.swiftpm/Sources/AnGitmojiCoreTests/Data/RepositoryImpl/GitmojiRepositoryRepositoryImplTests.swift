import XCTest
@testable import AnGitmojiCore

final class GitmojiRepositoryRepositoryImplTests: XCTestCase {
    private static let gitmojiGroupEntityName: String = "GitmojiGroup"
    private var gitmojiRepositoryImpl: GitmojiRepositoryImpl?
    
    override func setUp() async throws {
        gitmojiRepositoryImpl = .init(coreDataDataSource: LocalCoreData.shared)
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
    
    func testGitmojiGroupsWithDefaultFetchRequest() async throws {
        let _: [GitmojiGroup] = try await gitmojiRepositoryImpl!.gitmojiGroups(fetchRequest: nil)
    }
    
    func testGitmojiGroupsWithSortedFetchRequest() async throws {
        let fetchRequest: NSFetchRequest<GitmojiGroup> = .init(entityName: Self.gitmojiGroupEntityName)
        let _: [GitmojiGroup] = try await gitmojiRepositoryImpl!.gitmojiGroups(fetchRequest: fetchRequest)
    }
    
    func testAddRemoveSaveGitmoji() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiRepositoryImpl!.newGitmojiGroup
        let gitmoji: Gitmoji = try await gitmojiRepositoryImpl!.newGitmoji
        
//        gitmojiGroup.
    }
}
