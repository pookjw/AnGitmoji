import CoreData

final public class Gitmoji: NSManagedObject {
    public enum Semver: String {
        case major, minor, patch
    }
    
    @NSManaged public var code: String?
    @NSManaged public var agmDescription: String?
    @NSManaged public var emoji: String?
    @NSManaged public var name: String?
    @NSManaged private var agmSemver: String?
    
    public var semver: Semver? {
        get {
            guard let agmSemver: String else {
                return nil
            }
            return .init(rawValue: agmSemver)
        }
        set {
            agmSemver = newValue?.rawValue
        }
    }
}
