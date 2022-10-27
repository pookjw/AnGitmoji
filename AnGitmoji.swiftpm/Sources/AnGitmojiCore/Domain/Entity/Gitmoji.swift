import CoreData

public final class Gitmoji: NSManagedObject, @unchecked Sendable {
    @NSManaged public internal(set) var order: Int64
    @NSManaged public internal(set) var emoji: String
    @NSManaged public internal(set) var code: String
    @NSManaged public internal(set) var detail: String
    @NSManaged public internal(set) var name: String
    @NSManaged public internal(set) var semver: String?
    @NSManaged public internal(set) var group: GitmojiGroup?
    
    func map(from gitmojiJSONObject: GitmojiJSON.Object) {
        emoji = gitmojiJSONObject.emoji
        code = gitmojiJSONObject.code
        detail = gitmojiJSONObject.description
        name = gitmojiJSONObject.name
        semver = gitmojiJSONObject.semver
    }
}
