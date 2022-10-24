import CoreData

public final class Gitmoji: NSManagedObject {
    @NSManaged public var cdEmoji: String?
    @NSManaged public var cdCode: String?
    @NSManaged public var cdDetail: String?
    @NSManaged public var cdName: String?
    @NSManaged public var cdSemver: String?
    @NSManaged public var group: GitmojiGroup?
}
