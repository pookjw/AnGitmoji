@preconcurrency import XCTest
@testable import AnGitmojiCore

final class GitmojiRepositoryImplTests: XCTestCase, @unchecked Sendable {
    private var gitmojiRepositoryImpl: GitmojiRepositoryImpl!
    private var fetchRequest: NSFetchRequest<GitmojiGroup> {
        let fetchRequest: NSFetchRequest<GitmojiGroup> = .init(entityName: "GitmojiGroup")
        return fetchRequest
    }
    
    override func setUp() async throws {
        let gitmojiRepositoryImpl: GitmojiRepositoryImpl = .shared
        try await gitmojiRepositoryImpl.removeAllGitmojiGroups()
        self.gitmojiRepositoryImpl = gitmojiRepositoryImpl
        
        try await super.setUp()
    }
    
    override func tearDown() async throws {
        try await gitmojiRepositoryImpl?.removeAllGitmojiGroups()
        gitmojiRepositoryImpl = nil
        
        try await super.tearDown()
    }
    
    func testContext() async throws {
        let _: NSManagedObjectContext = try await gitmojiRepositoryImpl.context
    }
    
    func testDidSaveStream() async throws {
        let expectation: XCTestExpectation = .init(description: "Stream")
        
        let task: Task<Void, Never> = .detached { [self] in
            do {
                for await _ in try await gitmojiRepositoryImpl.didSaveStream {
                    expectation.fulfill()
                }
            } catch {
                XCTFail("\(error)")
            }
        }
        
        try await Task.sleep(until: .now + .seconds(1.0), clock: .continuous)
        try await gitmojiRepositoryImpl.saveChanges()
        
        wait(for: [expectation], timeout: 5.0)
        task.cancel()
    }
    
    func testNewGitmojiGroup() async throws {
        let _: GitmojiGroup = try await gitmojiRepositoryImpl.newGitmojiGroup
    }
    
    func testNewGitmoji() async throws {
        let _: Gitmoji = try await gitmojiRepositoryImpl.newGitmoji
    }
    
    func testGitmojiGroups() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiRepositoryImpl.newGitmojiGroup
        try await gitmojiRepositoryImpl.saveChanges()
        
        let gitmojiGroups: [GitmojiGroup] = try await gitmojiRepositoryImpl.gitmojiGroups(fetchRequest: fetchRequest)
        XCTAssertTrue(gitmojiGroups.contains(gitmojiGroup))
    }

    func testGitmojiGroupsCountZero() async throws {
        let count: Int = try await gitmojiRepositoryImpl.gitmojiGroupsCount(fetchRequest: fetchRequest)
        XCTAssertTrue(count == .zero)
    }
    
    func testGitmojiGroupsCountNotZero() async throws {
        let _: GitmojiGroup = try await gitmojiRepositoryImpl.newGitmojiGroup
        try await gitmojiRepositoryImpl.saveChanges()
        
        let count: Int = try await gitmojiRepositoryImpl!.gitmojiGroupsCount(fetchRequest: fetchRequest)
        XCTAssertTrue(count == 1)
    }
    
    func testRemoveGitmojiGroup() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiRepositoryImpl.newGitmojiGroup
        try await gitmojiRepositoryImpl.saveChanges()
        try await gitmojiRepositoryImpl.remove(gitmojiGroup: gitmojiGroup)
        try await gitmojiRepositoryImpl.saveChanges()
        let count: Int = try await gitmojiRepositoryImpl.gitmojiGroupsCount(fetchRequest: fetchRequest)
        XCTAssertTrue(count == .zero)
    }
    
    func testRemoveGitmoji() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiRepositoryImpl.newGitmojiGroup
        let gitmoji: Gitmoji = try await gitmojiRepositoryImpl.newGitmoji
        gitmojiGroup.addToGitmoji(gitmoji)
        try await gitmojiRepositoryImpl.saveChanges()
        try await gitmojiRepositoryImpl.remove(gitmoji: gitmoji)
        try await gitmojiRepositoryImpl.saveChanges()
        let count: Int = (try await gitmojiRepositoryImpl.gitmojiGroups(fetchRequest: fetchRequest)).first!.gitmoji.count
        XCTAssertTrue(count == .zero)
    }
    
    func testRemoveAllGitmojiGroups() async throws {
        let _: GitmojiGroup = try await gitmojiRepositoryImpl.newGitmojiGroup
        try await gitmojiRepositoryImpl.saveChanges()
        try await gitmojiRepositoryImpl.removeAllGitmojiGroups()
        let count: Int = try await gitmojiRepositoryImpl.gitmojiGroupsCount(fetchRequest: fetchRequest)
        XCTAssertTrue(count == .zero)
    }
}
