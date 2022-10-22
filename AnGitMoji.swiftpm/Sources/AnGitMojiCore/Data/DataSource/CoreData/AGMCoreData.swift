import Foundation
import Combine
import CoreData

protocol AGMCoreData {
    associatedtype PersistentContainer = NSPersistentContainer
    func container(entityName: String) async throws -> PersistentContainer
    func context(entityName: String) async throws -> NSManagedObjectContext
}
