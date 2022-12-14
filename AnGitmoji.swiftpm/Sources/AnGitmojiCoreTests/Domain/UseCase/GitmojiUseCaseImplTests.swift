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
        let context: NSManagedObjectContext = try await gitmojiUseCaseImpl.context
        XCTAssertNotNil(context.persistentStoreCoordinator)
    }
    
    func testContextObjC() async throws {
        let context: NSManagedObjectContext = try await gitmojiUseCaseImpl.context()
        XCTAssertNotNil(context.persistentStoreCoordinator)
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
        
        wait(for: [expectation], timeout: 3.0)
        task.cancel()
    }
    
    func testDidInsertObjectsStream() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        let expectation: XCTestExpectation = .init(description: "Stream")
        
        let task: Task<Void, Never> = .detached { [self] in
            do {
                for await insertedObjects in try await gitmojiUseCaseImpl.didInsertObjectsStream {
                    XCTAssertTrue(insertedObjects.contains(gitmojiGroup))
                    expectation.fulfill()
                }
            } catch {
                XCTFail("\(error)")
            }
        }
        
        try await Task.sleep(until: .now + .seconds(1.0), clock: .continuous)
        try await gitmojiUseCaseImpl.saveChanges()
        
        wait(for: [expectation], timeout: 3.0)
        task.cancel()
    }
    
    func testDidUpdateObjectsStream() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        try await gitmojiUseCaseImpl.saveChanges()
        
        gitmojiGroup.name = "Hello World!"
        
        let expectation: XCTestExpectation = .init(description: "Stream")
        
        let task: Task<Void, Never> = .detached { [self] in
            do {
                for await updatedObjects in try await gitmojiUseCaseImpl.didUpdateObjectsStream {
                    XCTAssertTrue(updatedObjects.contains(gitmojiGroup))
                    expectation.fulfill()
                }
            } catch {
                XCTFail("\(error)")
            }
        }
        
        try await Task.sleep(until: .now + .seconds(1.0), clock: .continuous)
        try await gitmojiUseCaseImpl.saveChanges()
        
        wait(for: [expectation], timeout: 3.0)
        task.cancel()
    }
    
    func testDidDeleteObjectsStream() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        try await gitmojiUseCaseImpl.saveChanges()
        try await gitmojiUseCaseImpl.remove(gitmojiGroup: gitmojiGroup)
        
        let expectation: XCTestExpectation = .init(description: "Stream")
        
        let task: Task<Void, Never> = .detached { [self] in
            do {
                for await deletedObjects in try await gitmojiUseCaseImpl.didDeleteObjectsStream {
                    XCTAssertTrue(deletedObjects.contains(gitmojiGroup))
                    expectation.fulfill()
                }
            } catch {
                XCTFail("\(error)")
            }
        }
        
        try await Task.sleep(until: .now + .seconds(1.0), clock: .continuous)
        try await gitmojiUseCaseImpl.saveChanges()
        
        wait(for: [expectation], timeout: 3.0)
        task.cancel()
    }
    
    func testJSONData() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.createDefaultGitmojiGroupIfNeeded(force: true)!
        let jsonData: Data = try await gitmojiUseCaseImpl.jsonData(from: gitmojiGroup)
        XCTAssertFalse(jsonData.isEmpty)
        
        print(String(data: jsonData, encoding: .utf8))
    }
    
    func testCreateDefaultGitmojiGroupIfNeeded() async throws {
        let firstGitmojiGroup: GitmojiGroup? = try await gitmojiUseCaseImpl.createDefaultGitmojiGroupIfNeeded(force: false)
        XCTAssertNotNil(firstGitmojiGroup)
        let secondGitmojiGroup: GitmojiGroup?  = try await gitmojiUseCaseImpl.createDefaultGitmojiGroupIfNeeded(force: false)
        XCTAssertNil(secondGitmojiGroup)
        let thirdGitmojiGroup: GitmojiGroup? = try await gitmojiUseCaseImpl.createDefaultGitmojiGroupIfNeeded(force: true)
        XCTAssertNil(thirdGitmojiGroup)
        
        let gitmojiGroups: [GitmojiGroup] = try await gitmojiUseCaseImpl.gitmojiGroups(fetchRequest: nil)
        XCTAssertTrue(gitmojiGroups.count == 2)
        let gitmojiGroup: GitmojiGroup = gitmojiGroups.first!
        await gitmojiUseCaseImpl.conditionSafe {
            XCTAssertTrue(gitmojiGroup.gitmojis.count > 0)
        }
    }
    
    func testCreateGitmojiGroup() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.createGitmojiGroup(from: defaultGitmojiURL!, name: "Test")
        await gitmojiUseCaseImpl.conditionSafe {
            XCTAssertTrue(gitmojiGroup.gitmojis.count > 0)
            XCTAssertEqual(gitmojiGroup.name, "Test")
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
            XCTAssertTrue(gitmojiGroup.gitmojis.contains(firstGitmoji))
            XCTAssertTrue(gitmojiGroup.gitmojis.contains(secondGitmoji))
            XCTAssertTrue(gitmojiGroup.gitmojis.contains(thirdGitmoji))
            
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: firstGitmoji) == 0)
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: secondGitmoji) == 1)
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: thirdGitmoji) == 2)
        }
    }
    
    func testNewGitmojiObjC() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        let firstGitmoji: Gitmoji = try await gitmojiUseCaseImpl._newGitmoji(to: gitmojiGroup)
        let secondGitmoji: Gitmoji = try await gitmojiUseCaseImpl._newGitmoji(to: gitmojiGroup, index: 1)
        let thirdGitmoji: Gitmoji = try await gitmojiUseCaseImpl._newGitmoji(to: gitmojiGroup)
        
        await gitmojiUseCaseImpl.conditionSafe {
            XCTAssertTrue(gitmojiGroup.gitmojis.contains(firstGitmoji))
            XCTAssertTrue(gitmojiGroup.gitmojis.contains(secondGitmoji))
            XCTAssertTrue(gitmojiGroup.gitmojis.contains(thirdGitmoji))
            
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: firstGitmoji) == 0)
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: secondGitmoji) == 1)
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: thirdGitmoji) == 2)
        }
    }
    
    func testGitmojiGroups() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        try await gitmojiUseCaseImpl.saveChanges()
        
        let gitmojiGroups: [GitmojiGroup] = try await gitmojiUseCaseImpl.gitmojiGroups(fetchRequest: nil)
        XCTAssertTrue(gitmojiGroups.contains(gitmojiGroup))
    }
    
    func testGitmojis() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        let gitmoji: Gitmoji = try await gitmojiUseCaseImpl.newGitmoji(to: gitmojiGroup, index: nil)
        try await gitmojiUseCaseImpl.saveChanges()
        
        let gitmojis: [Gitmoji] = try await gitmojiUseCaseImpl.gitmojis(fetchRequest: nil)
        XCTAssertTrue(gitmojis.contains(gitmoji))
    }
    
    func testObjectWithObjectID() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        try await gitmojiUseCaseImpl.saveChanges()
        
        let fetchedGitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.object(with: gitmojiGroup.objectID)
        XCTAssertEqual(gitmojiGroup.objectID, fetchedGitmojiGroup.objectID)
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
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: firstGitmoji) == 1)
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: secondGitmoji) == 0)
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: thirdGitmoji) == 2)
            
            // 3 2 1
            try await gitmojiUseCaseImpl.move(gitmoji: thirdGitmoji, to: 0)
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: firstGitmoji) == 2)
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: secondGitmoji) == 1)
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: thirdGitmoji) == 0)
            
            // 1 3 2
            try await gitmojiUseCaseImpl.move(gitmoji: firstGitmoji, to: 0)
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: firstGitmoji) == 0)
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: secondGitmoji) == 2)
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: thirdGitmoji) == 1)
            
            // 1 2 3
            try await gitmojiUseCaseImpl.move(gitmoji: thirdGitmoji, to: 2)
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: firstGitmoji) == 0)
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: secondGitmoji) == 1)
            XCTAssertTrue(gitmojiGroup.gitmojis.index(of: thirdGitmoji) == 2)
        }
    }
    
    func testRemoveGitmojiGroup() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        let _: Gitmoji = try await gitmojiUseCaseImpl.newGitmoji(to: gitmojiGroup, index: nil)
        
        try await gitmojiUseCaseImpl.saveChanges()
        try await gitmojiUseCaseImpl.remove(gitmojiGroup: gitmojiGroup)
        try await gitmojiUseCaseImpl.saveChanges()
        
        let context: NSManagedObjectContext = try await gitmojiUseCaseImpl.context
        
        let gitmojiGroupCount: Int = try await gitmojiUseCaseImpl.gitmojiGroupsCount(fetchRequest: GitmojiGroup.fetchRequest)
        let gitmojiCount: Int = try context.count(for: Gitmoji.fetchRequest)
        
        XCTAssertTrue(gitmojiGroupCount == .zero)
        XCTAssertTrue(gitmojiCount == .zero)
    }
    
    func testRemoveGitmoji() async throws {
        let gitmojiGroup: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        let gitmoji: Gitmoji = try await gitmojiUseCaseImpl.newGitmoji(to: gitmojiGroup, index: nil)
        try await gitmojiUseCaseImpl.remove(gitmoji: gitmoji)
        XCTAssertTrue(gitmojiGroup.gitmojis.count == .zero)
    }
    
    func testRemoveAllGitmojiGroups() async throws {
        let _: GitmojiGroup = try await gitmojiUseCaseImpl.newGitmojiGroup
        try await gitmojiUseCaseImpl.saveChanges()
        try await gitmojiUseCaseImpl.removeAllGitmojiGroups()
        let count: Int = try await gitmojiUseCaseImpl.gitmojiGroupsCount(fetchRequest: nil)
        XCTAssertTrue(count == .zero)
    }
}
