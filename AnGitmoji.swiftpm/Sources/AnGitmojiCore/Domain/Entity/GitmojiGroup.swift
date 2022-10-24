import CoreData

public final class GitmojiGroup: NSManagedObject {
    @NSManaged public var gitmoji: NSSet?
    
    @objc(addGitmojiObject:)
    @NSManaged public func addToGitmoji(_ value: Gitmoji)

    @objc(removeGitmojiObject:)
    @NSManaged public func removeFromGitmoji(_ value: Gitmoji)

    @objc(addGitmoji:)
    @NSManaged public func addToGitmoji(_ values: NSSet)

    @objc(removeGitmoji:)
    @NSManaged public func removeFromGitmoji(_ values: NSSet)
}
