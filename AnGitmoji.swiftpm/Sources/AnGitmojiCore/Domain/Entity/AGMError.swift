import Foundation

public enum AGMError: Error {
    case failedToFoundMomdURL(entityName: String)
    case failedToInitManagedObjectModel(entityName: String)
    case failedToGetEntityNameFromFetchRequest
}
