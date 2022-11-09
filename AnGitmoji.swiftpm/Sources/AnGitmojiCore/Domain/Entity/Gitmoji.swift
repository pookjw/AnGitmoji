import CoreData

public final class Gitmoji: NSManagedObject, @unchecked Sendable {
    @objc(_fetchRequest) public static var fetchRequest: NSFetchRequest<Gitmoji> {
        return .init(entityName: "Gitmoji")
    }
    
    @NSManaged public var emoji: String
    @NSManaged public var code: String
    @NSManaged public var detail: String
    @NSManaged public var name: String
    @NSManaged public var semver: String?
    @NSManaged public var count: Int
    @NSManaged public internal(set) var group: GitmojiGroup?
    
    func map(from gitmojiJSONObject: GitmojiJSON.Object) {
        emoji = gitmojiJSONObject.emoji
        code = gitmojiJSONObject.code
        detail = gitmojiJSONObject.description
        name = gitmojiJSONObject.name
        semver = gitmojiJSONObject.semver
    }
}

extension Gitmoji: Identifiable {
    
}
