import Foundation
import Combine
import CoreData

protocol CoreDataDataSource {
    associatedtype PersistentContainer = NSPersistentContainer
    func container(modelName: String) async throws -> PersistentContainer
    func context(modelName: String) async throws -> NSManagedObjectContext
}
