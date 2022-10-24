import CoreData

public final class Gitmoji: NSManagedObject {
    public enum Semver: String {
        case major, minor, patch
    }
    
    public var code: String {
        get {
            cdCode ?? ""
        }
        set {
            cdCode = newValue
        }
    }
    
    public var detail: String {
        get {
            cdDetail ?? ""
        }
        set {
            cdDetail = newValue
        }
    }
    
    public var emoji: String {
        get {
            cdEmoji ?? ""
        }
        set {
            cdEmoji = newValue
        }
    }
    
    public var name: String {
        get {
            cdName ?? ""
        }
        set {
            cdName = newValue
        }
    }
    
    public var semver: Semver? {
        get {
            guard let cdSemver: String else {
                return nil
            }
            return .init(rawValue: cdSemver)
        }
        set {
            cdSemver = newValue?.rawValue
        }
    }
    
    @NSManaged private var cdCode: String?
    @NSManaged private var cdDetail: String?
    @NSManaged private var cdEmoji: String?
    @NSManaged private var cdName: String?
    @NSManaged private var cdSemver: String?
}
