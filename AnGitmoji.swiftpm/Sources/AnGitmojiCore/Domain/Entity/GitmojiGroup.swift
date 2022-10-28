import CoreData

public final class GitmojiGroup: NSManagedObject, @unchecked Sendable {
    @NSManaged public internal(set) var index: Int
    @NSManaged public internal(set) var gitmoji: NSOrderedSet
    
    @objc(insertObject:inGitmojiAtIndex:)
    @NSManaged func insertIntoGitmoji(_ value: Gitmoji, at idx: Int)

    @objc(removeObjectFromGitmojiAtIndex:)
    @NSManaged func removeFromGitmoji(at idx: Int)

    @objc(insertGitmoji:atIndexes:)
    @NSManaged func insertIntoGitmoji(_ values: [Gitmoji], at indexes: NSIndexSet)

    @objc(removeGitmojiAtIndexes:)
    @NSManaged func removeFromGitmoji(at indexes: NSIndexSet)

    @objc(replaceObjectInGitmojiAtIndex:withObject:)
    @NSManaged func replaceGitmoji(at idx: Int, with value: Gitmoji)

    @objc(replaceGitmojiAtIndexes:withGitmoji:)
    @NSManaged func replaceGitmoji(at indexes: NSIndexSet, with values: [Gitmoji])

    @objc(addGitmojiObject:)
    @NSManaged func addToGitmoji(_ value: Gitmoji)

    @objc(removeGitmojiObject:)
    @NSManaged func removeFromGitmoji(_ value: Gitmoji)

    @objc(addGitmoji:)
    @NSManaged func addToGitmoji(_ values: NSOrderedSet)

    @objc(removeGitmoji:)
    @NSManaged func removeFromGitmoji(_ values: NSOrderedSet)
}
