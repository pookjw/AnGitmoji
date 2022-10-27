import Foundation
import Combine
import CoreData

protocol CoreDataDataSource: Sendable {
    func container(modelName: String) async throws -> NSPersistentContainer
    func context(modelName: String) async throws -> NSManagedObjectContext
}
