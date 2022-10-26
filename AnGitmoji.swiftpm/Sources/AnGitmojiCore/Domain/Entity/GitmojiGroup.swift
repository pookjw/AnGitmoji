import CoreData

public final class GitmojiGroup: NSManagedObject {
    @NSManaged public var order: Int64
    @NSManaged public var gitmoji: NSOrderedSet
    
    @objc(insertObject:inGitmojiAtIndex:)
    @NSManaged public func insertIntoGitmoji(_ value: Gitmoji, at idx: Int)

    @objc(removeObjectFromGitmojiAtIndex:)
    @NSManaged public func removeFromGitmoji(at idx: Int)

    @objc(insertGitmoji:atIndexes:)
    @NSManaged public func insertIntoGitmoji(_ values: [Gitmoji], at indexes: NSIndexSet)

    @objc(removeGitmojiAtIndexes:)
    @NSManaged public func removeFromGitmoji(at indexes: NSIndexSet)

    @objc(replaceObjectInGitmojiAtIndex:withObject:)
    @NSManaged public func replaceGitmoji(at idx: Int, with value: Gitmoji)

    @objc(replaceGitmojiAtIndexes:withGitmoji:)
    @NSManaged public func replaceGitmoji(at indexes: NSIndexSet, with values: [Gitmoji])

    @objc(addGitmojiObject:)
    @NSManaged public func addToGitmoji(_ value: Gitmoji)

    @objc(removeGitmojiObject:)
    @NSManaged public func removeFromGitmoji(_ value: Gitmoji)

    @objc(addGitmoji:)
    @NSManaged public func addToGitmoji(_ values: NSOrderedSet)

    @objc(removeGitmoji:)
    @NSManaged public func removeFromGitmoji(_ values: NSOrderedSet)
}
