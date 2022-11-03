import CoreData

public final class GitmojiGroup: NSManagedObject, @unchecked Sendable {
    public static var fetchRequest: NSFetchRequest<GitmojiGroup> {
        return .init(entityName: "GitmojiGroup")
    }
    
    @NSManaged public internal(set) var index: Int
    @NSManaged public var name: String
    @NSManaged public internal(set) var gitmojis: NSOrderedSet
    
    @objc(insertObject:inGitmojisAtIndex:)
    @NSManaged func insertIntoGitmojis(_ value: Gitmoji, at idx: Int)

    @objc(removeObjectFromGitmojisAtIndex:)
    @NSManaged func removeFromGitmojis(at idx: Int)

    @objc(insertGitmojis:atIndexes:)
    @NSManaged func insertIntoGitmojis(_ values: [Gitmoji], at indexes: NSIndexSet)

    @objc(removeGitmojisAtIndexes:)
    @NSManaged func removeFromGitmojis(at indexes: NSIndexSet)

    @objc(replaceObjectInGitmojisAtIndex:withObject:)
    @NSManaged func replaceGitmojis(at idx: Int, with value: Gitmoji)

    @objc(replaceGitmojisAtIndexes:withGitmoji:)
    @NSManaged func replaceGitmojis(at indexes: NSIndexSet, with values: [Gitmoji])

    @objc(addGitmojisObject:)
    @NSManaged func addToGitmojis(_ value: Gitmoji)

    @objc(removeGitmojisObject:)
    @NSManaged func removeFromGitmojis(_ value: Gitmoji)

    @objc(addGitmojis:)
    @NSManaged func addToGitmojis(_ values: NSOrderedSet)

    @objc(removeGitmojis:)
    @NSManaged func removeFromGitmojis(_ values: NSOrderedSet)
}
