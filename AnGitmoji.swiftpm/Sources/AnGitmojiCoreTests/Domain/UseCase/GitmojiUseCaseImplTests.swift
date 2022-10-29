import XCTest
import CoreData
@testable import AnGitmojiCore

final class GitmojiUseCaseImplTests: XCTestCase, @unchecked Sendable {
    private var gitmojiUseCaseImpl: GitmojiUseCaseImpl!
    private var defaultGitmojiURL: URL? {
        var components: URLComponents = .init()
        components.scheme = "https"
        components.host = "raw.githubusercontent.com"
        components.path = "/carloscuesta/gitmoji/master/src/data/gitmojis.json"
        
        return components.url
    }
    
    override func setUp() async throws {
        let gitmojiRepositoryImpl: GitmojiRepositoryImpl = .shared
        let gitmojiJSONNetwork: GitmojiJSONNetwork = .init()
        let gitmojiJSONRepository: GitmojiJSONRepositoryImpl = .init(gitmojiDataSource: gitmojiJSONNetwork)
        let gitmojiUseCaseImpl: GitmojiUseCaseImpl = .init(gitmojiRepository: gitmojiRepositoryImpl, gitmojiJSONRepository: gitmojiJSONRepository)
        
        try await gitmojiUseCaseImpl.removeAllGitmojiGroups()
        self.gitmojiUseCaseImpl = gitmojiUseCaseImpl
        
        try await super.setUp()
    }
    
    override func tearDown() async throws {
        try await gitmojiUseCaseImpl?.removeAllGitmojiGroups()
        gitmojiUseCaseImpl = nil
        
        try await super.tearDown()
    }
    
    func testContext() async throws {
        let _: NSManagedObjectContext = try await gitmojiUseCaseImpl.context
    }
    
    func testDidSaveStream() async throws {
        let expectation: XCTestExpectation = .init(description: "Stream")
        
        let task: Task<Void, Never> = .detached { [self] in
            do {
                for await _ in try await gitmojiUseCaseImpl.didSaveStream {
                    expectation.fulfill()
                }
            } catch {
                XCTFail("\(error)")
            }
        }
        
        try await Task.sleep(until: .now + .seconds(1.0), clock: .continuous)
        try await gitmojiUseCaseImpl.saveChanges()
        
        wait(for: [expectation], timeout: 5.0)
        task.cancel()
    }
    
    func testCreateDefaultGitmojiGroupIfNeeded() async throws {
        let isCreated: Bool = try await gitmojiUseCaseImpl.createDefaultGitmojiGroupIfNeeded()
        XCTAssertTrue(isCreated)
        
        let gitmojiGroups: [GitmojiGroup] = try await gitmojiUseCaseImpl.gitmojiGroups(fetchRequest: nil)
        XCTAssertTrue(gitmojiGroups.count == 1)
        let gitmojiGroup: GitmojiGroup = gitmojiGroups.first!
        await gitmojiUseCaseImpl.conditionSafe {
            XCTAssertTrue(gitmojiGroup.gitmoji.count > 0)
        }
    }
    
    func testCreateGitmojiGroup() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.createGitmojiGroup(from: defaultGitmojiURL!)
        await gitmojiUseCaseImpl.conditionSafe {
            XCTAssertTrue(gitmojiGroup.gitmoji.count > 0)
        }
    }
    
    func testNewGitmojiGroup() async throws {
        let firstGitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        let secondGitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        let thirdGitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        
        await gitmojiUseCaseImpl.conditionSafe {
            XCTAssertTrue(firstGitmojiGroup.index == 0)
            XCTAssertTrue(secondGitmojiGroup.index == 1)
            XCTAssertTrue(thirdGitmojiGroup.index == 2)
        }
    }
    
    func testNewGitmoji() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        let firstGitmoji: Gitmoji = try await gitmojiUseCaseImpl.newGitmoji(to: gitmojiGroup, index: nil)
        let secondGitmoji: Gitmoji = try await gitmojiUseCaseImpl.newGitmoji(to: gitmojiGroup, index: 1)
        let thirdGitmoji: Gitmoji = try await gitmojiUseCaseImpl.newGitmoji(to: gitmojiGroup, index: nil)
        
        await gitmojiUseCaseImpl.conditionSafe {
            XCTAssertTrue(gitmojiGroup.gitmoji.contains(firstGitmoji))
            XCTAssertTrue(gitmojiGroup.gitmoji.contains(secondGitmoji))
            XCTAssertTrue(gitmojiGroup.gitmoji.contains(thirdGitmoji))
            
            XCTAssertTrue(gitmojiGroup.gitmoji.index(of: firstGitmoji) == 0)
            XCTAssertTrue(gitmojiGroup.gitmoji.index(of: secondGitmoji) == 1)
            XCTAssertTrue(gitmojiGroup.gitmoji.index(of: thirdGitmoji) == 2)
        }
    }
    
    func testGitmojiGroups() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        try await gitmojiUseCaseImpl.saveChanges()
        
        let gitmojiGroups: [GitmojiGroup] = try await gitmojiUseCaseImpl.gitmojiGroups(fetchRequest: nil)
        XCTAssertTrue(gitmojiGroups.contains(gitmojiGroup))
    }
    
    func testGitmojiGroupsCountZero() async throws {
        let count: Int = try await gitmojiUseCaseImpl.gitmojiGroupsCount(fetchRequest: nil)
        XCTAssertTrue(count == .zero)
    }
    
    func testGitmojiGroupsCountNotZero() async throws {
        let _: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        try await gitmojiUseCaseImpl!.saveChanges()
        
        let count: Int = try await gitmojiUseCaseImpl!.gitmojiGroupsCount(fetchRequest: nil)
        XCTAssertTrue(count == 1)
    }
    
    func testMoveGitmojiGroup() async throws {
        let firstGitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        let secondGitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        let thirdGitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        
        try await gitmojiUseCaseImpl.conditionSafe {
            // 2 1 3
            try await gitmojiUseCaseImpl.move(gitmojiGroup: firstGitmojiGroup, to: 1)
            XCTAssertTrue(firstGitmojiGroup.index == 1)
            XCTAssertTrue(secondGitmojiGroup.index == 0)
            XCTAssertTrue(thirdGitmojiGroup.index == 2)
            
            // 3 2 1
            try await gitmojiUseCaseImpl.move(gitmojiGroup: thirdGitmojiGroup, to: 0)
            XCTAssertTrue(firstGitmojiGroup.index == 2)
            XCTAssertTrue(secondGitmojiGroup.index == 1)
            XCTAssertTrue(thirdGitmojiGroup.index == 0)
            
            // 1 3 2
            try await gitmojiUseCaseImpl.move(gitmojiGroup: firstGitmojiGroup, to: 0)
            XCTAssertTrue(firstGitmojiGroup.index == 0)
            XCTAssertTrue(secondGitmojiGroup.index == 2)
            XCTAssertTrue(thirdGitmojiGroup.index == 1)
            
            // 1 2 3
            try await gitmojiUseCaseImpl.move(gitmojiGroup: thirdGitmojiGroup, to: 2)
            XCTAssertTrue(firstGitmojiGroup.index == 0)
            XCTAssertTrue(secondGitmojiGroup.index == 1)
            XCTAssertTrue(thirdGitmojiGroup.index == 2)
        }
    }
    
    func testMoveGitmoji() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        let firstGitmoji: Gitmoji = try await gitmojiUseCaseImpl.newGitmoji(to: gitmojiGroup, index: 0)
        let secondGitmoji: Gitmoji = try await gitmojiUseCaseImpl.newGitmoji(to: gitmojiGroup, index: 1)
        let thirdGitmoji: Gitmoji = try await gitmojiUseCaseImpl.newGitmoji(to: gitmojiGroup, index: nil)
        
        try await gitmojiUseCaseImpl.conditionSafe {
            // 2 1 3
            try await gitmojiUseCaseImpl.move(gitmoji: firstGitmoji, to: 1)
            XCTAssertTrue(gitmojiGroup.gitmoji.index(of: firstGitmoji) == 1)
            XCTAssertTrue(gitmojiGroup.gitmoji.index(of: secondGitmoji) == 0)
            XCTAssertTrue(gitmojiGroup.gitmoji.index(of: thirdGitmoji) == 2)
            
            // 3 2 1
            try await gitmojiUseCaseImpl.move(gitmoji: thirdGitmoji, to: 0)
            XCTAssertTrue(gitmojiGroup.gitmoji.index(of: firstGitmoji) == 2)
            XCTAssertTrue(gitmojiGroup.gitmoji.index(of: secondGitmoji) == 1)
            XCTAssertTrue(gitmojiGroup.gitmoji.index(of: thirdGitmoji) == 0)
            
            // 1 3 2
            try await gitmojiUseCaseImpl.move(gitmoji: firstGitmoji, to: 0)
            XCTAssertTrue(gitmojiGroup.gitmoji.index(of: firstGitmoji) == 0)
            XCTAssertTrue(gitmojiGroup.gitmoji.index(of: secondGitmoji) == 2)
            XCTAssertTrue(gitmojiGroup.gitmoji.index(of: thirdGitmoji) == 1)
            
            // 1 2 3
            try await gitmojiUseCaseImpl.move(gitmoji: thirdGitmoji, to: 2)
            XCTAssertTrue(gitmojiGroup.gitmoji.index(of: firstGitmoji) == 0)
            XCTAssertTrue(gitmojiGroup.gitmoji.index(of: secondGitmoji) == 1)
            XCTAssertTrue(gitmojiGroup.gitmoji.index(of: thirdGitmoji) == 2)
        }
    }
    
    func testRemoveGitmojiGroup() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        try await gitmojiUseCaseImpl.saveChanges()
        
        try await gitmojiUseCaseImpl.remove(gitmojiGroup: gitmojiGroup)
        try await gitmojiUseCaseImpl.saveChanges()
        
        let count: Int = try await gitmojiUseCaseImpl.gitmojiGroupsCount(fetchRequest: nil)
        XCTAssertTrue(count == .zero)
    }
    
    func testRemoveGitmoji() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        let gitmoji: Gitmoji = try await gitmojiUseCaseImpl.newGitmoji(to: gitmojiGroup, index: nil)
        try await gitmojiUseCaseImpl.remove(gitmoji: gitmoji)
        XCTAssertTrue(gitmojiGroup.gitmoji.count == .zero)
    }
    
    func testRemoveAllGitmojiGroups() async throws {
        let _: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        try await gitmojiUseCaseImpl.saveChanges()
        try await gitmojiUseCaseImpl.removeAllGitmojiGroups()
        let count: Int = try await gitmojiUseCaseImpl.gitmojiGroupsCount(fetchRequest: nil)
        XCTAssertTrue(count == .zero)
    }
}
