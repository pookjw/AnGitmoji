import CoreData

public final class Gitmoji: NSManagedObject {
    @NSManaged public var order: Int
    @NSManaged public var emoji: String
    @NSManaged public var code: String
    @NSManaged public var detail: String
    @NSManaged public var name: String
    @NSManaged public var semver: String
    @NSManaged public var group: GitmojiGroup
}
